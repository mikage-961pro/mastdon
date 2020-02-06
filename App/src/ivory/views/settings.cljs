(ns ivory.views.settings
  (:require [re-frame.core :as rf]
            [ivory.utils :as utils]
            [ivory.events :as events]
            [ivory.partials :refer [header content]]))

(defn- build-header []
  (header {:title "Settings"
           :separation true
           :buttons [{:callback #(rf/dispatch [::events/set-view :toots])
                      :icon "ion-ios-arrow-back"
                      :left? true}
                     {:callback #(rf/dispatch [::events/signout])
                      :icon "ion-ios-log-out"}]}))

(defn- build-content []
  (content
    [:div.placeholder "There will be things here in the future :)"]))

(defn build []
  "Construct the view out of all the parts."
  (utils/build
    (build-header)
    (build-content)))