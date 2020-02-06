(ns ivory.utils
  (:require [re-frame.core :as rf]))

(defn time-ago 
  "Provided a timestamp, it returns it relative to current time.
  For example: 1m, 5h, 12d, etc."
  [time]
  (let [provided-time (inst-ms (new js/Date time))
        current-time (inst-ms (js/Date.))
        difference (- current-time provided-time)
        minute (* 60 1000)
        hour (* minute 60)
        day (* hour 24)
        month (* day 30)
        year (* day 365)]
    (cond
      (< difference minute) (str (.round js/Math (/ difference 1000)) "s")
      (< difference hour) (str (.round js/Math (/ difference minute)) "m")
      (< difference day) (str (.round js/Math (/ difference hour)) "h")
      (< difference month) (str (.round js/Math (/ difference day)) "d")
      (< difference year) (str (.round js/Math (/ difference month)) "m")
      :else (str (.round js/Math (/ difference year)) "y"))))
        
(defn build 
  "Construct the main app content"
  [& content]
  (into [:div.app-construct] content))

(defn find-in-collection
  "Finds the first value from coll that satisfies pred.
  Returns nil if it doesn't find such a value."
  [pred coll]
  (some #(when (pred %)
           %)
        coll))

(defn update-in-collection 
  "Update item that matches predicate in a given collection with provided {:key :value}"
  [pred coll {:keys [key value]}]
  (vec (for [item coll]
         (if (pred item)
           (assoc item key value)
           item))))

(defn remove-from-collection
  "Remove item that matches predicate from given collection"
  [pred coll]
  (let [pred* (complement pred)]
    (cond
      (map? coll) (->> coll
                       (filter (fn [[k coll]] (and (pred* k) (pred* coll))))
                       (map (fn [[k coll]]
                              [k (remove-from-collection pred coll)]))
                       (into {}))
      (sequential? coll) (->> coll
                              (filter pred*)
                              (map (partial remove-from-collection pred))
                              (into (empty coll)))
      :default coll)))

(defn parse-json [json]
  (js->clj (.parse js/JSON json) :keywordize-keys true))

(defn listen-for-viewport-change [callback]
  (callback (.-innerWidth js/window))
  (set!
   (.-onresize js/window)
   (fn [event]
     (callback (.-innerWidth js/window)))))

(defn listen-for-pull-event [callback]
  (set!
    (.-onload js/window)
    (fn []
      (js/WebPullToRefresh.init #js {:contentEl (.querySelector js/document "#app")
                                     :loadingFunction (fn []
                                                        (new js/Promise (fn [resolve reject]
                                                                          (callback)
                                                                          (resolve))))})))


  #_(let [ptr (js/PullToRefresh.init #js {:onRefresh #(callback)})]))

