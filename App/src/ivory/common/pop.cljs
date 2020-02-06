(ns ivory.common.pop
  (:require [re-frame.core :as rf]
            [ivory.events :as events]))

(defn- build->pop->actions [options]
  [:div.pop
   [:div.pop-actions
    (for [option options]
      ^{:key option} [:div.pop-action
                      {:on-click #(rf/dispatch [(get-in option [:callback :event]) (get-in option [:callback :event-value])])}
                      (get option :value)])
    [:div.pop-action.pop-action-cancel
     {:on-click #(rf/dispatch [::events/set-pop nil])}
     "Cancel"]]])

(defn- build->pop->alert [options]
  [:div.pop
   [:div.pop-alert
    [:h2 (get options :title)]
    [:p (get options :description)]
    [:div.pop-action.pop-action-cancel
     {:on-click #(rf/dispatch [::events/set-pop nil])}
     "Okay"]]])

(defn build [{:keys [type options]}]
  (cond
    (= "actions" type) (build->pop->actions options)
    (= "alert" type) (build->pop->alert options)
    :else nil))