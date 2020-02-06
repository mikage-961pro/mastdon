(ns ivory.views.timelines
  (:require [re-frame.core :as rf]
            [ivory.events :as events]
            [ivory.subscriptions :as subscriptions]
            [ivory.partials :as partials :refer [header content footer]]
            [ivory.common.timeline :as timeline]
            [ivory.common.composer :as composer]
            [ivory.common.pop :as pop]
            [ivory.utils :as utils]
            [reagent.core :as r]))

(defn- build-header->tooting []
  (let [reply-to-toot @(rf/subscribe [::subscriptions/reply-to-toot])]
    (header {:title (if reply-to-toot "Reply" "Compose")
                 :left-button {:callback #(do (rf/dispatch [::events/toot])
                                              (rf/dispatch [::events/set-reply-to-toot nil]))
                               :icon "ion-ios-arrow-back"}
                 :right-button {:callback #(do (rf/dispatch [::events/post-toot (get @composer/composer-state :content)])
                                               (swap! composer/composer-state assoc :content nil))
                                :icon "ion-ios-send"}})))

(defn- build-header->timeline []
  (let [timeline @(rf/subscribe [::subscriptions/timeline])]
    (header {:title (cond
                      (= :home timeline) "Home"
                      (= :notifications timeline) "Notifications"
                      (= :local timeline) "Local"
                      (= :federated timeline) "Federated")
             :left-button {:callback nil
                           :icon "ion-ios-contact"}
             :right-button {:callback #(rf/dispatch [::events/toot])
                            :icon "ion-ios-create"}})))

(defn- build-header []
  (let [tooting? @(rf/subscribe [::subscriptions/tooting?])]
    (if tooting?
      (build-header->tooting)
      (build-header->timeline))))

(defn- build-footer []
  (let [timeline @(rf/subscribe [::subscriptions/timeline])]
    (footer [{:callback #(do (rf/dispatch [::events/get-toots :home])
                             (rf/dispatch [::events/set-timeline :home]))
              :icon "ion-ios-home"
              :class (when (= :home timeline) "active")}
             {:callback #(do (rf/dispatch [::events/get-notifications])
                             (rf/dispatch [::events/set-timeline :notifications]))
              :icon "ion-ios-pulse"
              :class (when (= :notifications timeline) "active")}
             {:callback #(do (rf/dispatch [::events/get-toots :local])
                             (rf/dispatch [::events/set-timeline :local]))
              :icon "ion-ios-git-compare"
              :class (when (= :local timeline) "active")}
             {:callback #(do (rf/dispatch [::events/get-toots :federated])
                             (rf/dispatch [::events/set-timeline :federated]))
              :icon "ion-ios-git-network"
              :class (when (= :federated timeline) "active")}])))

(defn build []
  "Construct the view out of all the parts."
  (let [pop @(rf/subscribe [::subscriptions/pop])]
    (utils/build
      (build-header)
      (timeline/build)
      (composer/build)
      (when pop
        (pop/build pop))
      (build-footer))))