(ns ivory.core
  (:require [reagent.core :as r]
            [re-frame.core :as rf]
            [ivory.events :as events]
            [ivory.subscriptions :as subscriptions]
            [ivory.listens :as listens]
            [ivory.views.settings :as views.settings]
            [ivory.views.timelines :as views.timelines]
            [ivory.utils :as utils]))

(defmulti app-view (fn [view] view) :default :error)

(defmethod app-view :settings []
  (views.settings/build))

(defmethod app-view :timelines []
  (views.timelines/build))

(defmethod app-view :toot []
  [:div "toot"])

(defmethod app-view :error []
  [:div "Something went wrong :("])

(defn app []
  (let [view @(rf/subscribe [::subscriptions/view])]
    (app-view view)))

(defn- set-up []
  (utils/listen-for-viewport-change (fn [screen-width] (rf/dispatch [::events/set-screen-width screen-width])))
  (utils/listen-for-pull-event (fn []
                                 (let [timeline @(rf/subscribe [::subscriptions/timeline])]
                                   (cond
                                     (= :notifications timeline) (rf/dispatch [::events/get-newer-notifications])
                                     :else (rf/dispatch [::events/get-newer-toots timeline]))))))

(defn ^:export run []
  (rf/dispatch-sync [::events/initialize])
  (rf/dispatch [::events/initialize-data])
  (set-up)
  (r/render [app] (js/document.getElementById "app")))