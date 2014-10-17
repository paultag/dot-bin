#!/usr/bin/env hy3
;;; doto.hy - do something to a bunch of other things.
;;;   Copyright (c) Paul R. Tagliamonte, MIT/Expat, 2014.
;;;


(import
  os sys subprocess
  [concurrent.futures [ThreadPoolExecutor]]
  [itertools [groupby]]
  [functools [partial]])


(defn consume [iter]
  "Consume an interator, disregarding the result"
  (for [- iter] -))

(defn splat [func]
  "Return a function which will accept args to splat against
   the passed function"
  (lambda [args] (apply func args)))


(defn split/command [data]
  "Given the sys.argv command line list, split the list at any 
   instances of \"--\""
  (let [[groups (list-comp (list y)
                           [(, x y) (groupby data (lambda [x] (= x "--")))]
                           (not x))]]
    (if (!= (len groups) 2)
      (raise (ValueError (.format "Error; {} command groups found, not 2"
                                  (len groups)))))
    groups))


(defn create-command [command target]
  "Replace any instances of {} with the target"
  (list-comp (if (= x "{}") target x) [x command]))


(defn run/target [command target]
  "Run the list of strings `command` against the target `target`"
  (with [[f (open os.devnull "w")]]
    (let [[ret (apply subprocess.call
                         [(create-command command target)]
                         {"stderr" f
                          "stdout" f})]]
      (, target ret))))


(defn run/targets [targets command]
  "Run the list of strings `command` against all targets `targets`,
   concurently running as many jobs as the pool will allow. Currently
   this is harcoded at 10, but that may change in the future."
  (let [[task (partial run/target command)]]
    (with [[executor (ThreadPoolExecutor 50)]]
      (yield-from (executor.map task targets)))))


(defn print/status [target status]
  "Show the result of the command against `target` in a human readable way."
  (let [[flag (cond [(= status 0) "[32m✓[0m"]
                    [true         "[31m✗[0m"])]]
    (print (.format "[ {} ] {}" flag target))))


(defn print/targets [iter]
  "Iterate over the commands we've run and print the status for each"
  (consume (map (splat print/status) iter)))


(defn main [_ &rest params]
  "Main entry point. params should be a sys.argv like list"

  (if (or (= params []) (not-in "--" params))
    (print "Usage:

    doto * -- ls

which will run `ls' against all folders and files in the directory,
either returning a checkmark (✓) for exit status 0, or an x (✗) for
a nonzero return status.")
    (->> (split/command params)
         (apply run/targets)
         print/targets)))

(if (= __name__ "__main__")
  (apply main sys.argv))
