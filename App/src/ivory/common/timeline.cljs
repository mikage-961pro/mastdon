(ns ivory.common.timeline
  (:require [reagent.core :as r]
            [re-frame.core :as rf]
            [ivory.events :as events]
            [ivory.subscriptions :as subscriptions]
            [ivory.partials :refer [content]]
            [ivory.utils :as utils]))

(defn- toot-class [toot]
  (cond
    (= "favourite" (get toot :type)) "favourite"
    (= "follow" (get toot :type)) "follow"
    (= "poll" (get toot :type)) "poll"
    (get toot :reblog) "reblog"))

(defn- toot-heading [toot]
  (let [reblog? (not (empty? (get toot :reblog)))
        avatar (if reblog? (get-in toot [:reblog :account :avatar]) (get-in toot [:account :avatar]))
        name (if reblog? (get-in toot [:reblog :account :display_name]) (get-in toot [:account :display_name]))
        handle (if reblog? (get-in toot [:reblog :account :acct]) (get-in toot [:account :acct]))
        created-at (if reblog? (get-in toot [:reblog :created_at]) (get toot :created_at))]
    [:div.toot-heading
     [:div.user-image
      {:style {:background (str "url(" avatar ")")}}]
     [:div.user-name-and-handle
      (when (not (empty? name))
        [:span.name name])
      [:span.handle (str "@" handle)]]
     [:div.user-posted-ago (utils/time-ago created-at)]]))

(defn- toot-content->notifications [toot]
  [:div.toot-content
   {:dangerouslySetInnerHTML {:__html (cond
                                        (= "follow" (get toot :type)) "<strong>Followed you.</strong>"
                                        (= "reblog" (get toot :type)) (str "<strong>Boosted your toot:</strong><blockquote>" (get-in toot [:status :content]) "</blockquote>")
                                        (= "favourite" (get toot :type)) (str "<strong>Favourited your toot:</strong><blockquote>" (get-in toot [:status :content]) "</blockquote>")
                                        :else (get-in toot [:status :content]))}}])

(defn- toot-content->default [toot]
  [:div.toot-content
   {:dangerouslySetInnerHTML {:__html (get toot :content)}}])

(defn- toot-content [toot]
  (let [timeline @(rf/subscribe [::subscriptions/timeline])]
    (if (= :notifications timeline)
      (toot-content->notifications toot)
      (toot-content->default toot))))

(defn- toot-media [toot]
  (let [reblog? (not (empty? (get toot :reblog)))
        media (if reblog? 
                (get-in toot [:reblog :media_attachments])
                (get toot :media_attachments))]
    (when-not (empty? media) 
      [:div.toot-media
       (for [item media]
         ^{:key item} [:div.media-item
                       {:style {:background (str "url(" (get item :preview_url) ")")}}])])))
      
(defn- toot-actions 
  "Displays toot actions, such as reply-to action, boost action and favourite action."
  [toot]
  (let [reblog? (not (empty? (get toot :reblog)))
        reblogged? (if reblog? (get-in toot [:reblog :reblogged]) (get toot :reblogged))
        favourited? (if reblog? (get-in toot [:reblog :favourited]) (get toot :favourited))
        timeline @(rf/subscribe [::subscriptions/timeline])
        type (get toot :type)
        toot (cond
               reblog? (get toot :reblog)
               (and (= :notifications timeline)
                    (= "mention" type)) (get toot :status)
               :else toot)
        show-actions? (cond 
                        (and (= :notifications timeline)
                             (or (= "follow" type)
                                 (= "reblog" type)
                                 (= "favourite" type))) nil
                        :else true)]
    (when show-actions?
      [:div.toot-actions
       [:div.btn
        {:on-click #(do (rf/dispatch [::events/toot])
                        (rf/dispatch [::events/set-reply-to-toot toot]))}
        [:i.icon.ion-ios-undo]]
       [:div.btn
        {:on-click #(if reblogged?
                      (rf/dispatch [::events/unboost-toot toot])
                      (rf/dispatch [::events/boost-toot toot]))
         :class (when reblogged? "boost highlight")}
        [:i.icon.ion-ios-repeat]]
       [:div.btn
        {:on-click #(if favourited?
                      (rf/dispatch [::events/unfavourite-toot toot])
                      (rf/dispatch [::events/favourite-toot toot]))
         :class (when favourited? "favourite highlight")}
        [:i.icon.ion-ios-star]]
       [:div.btn.btn-right
        {:on-click #(rf/dispatch [::events/set-pop {:type "actions"
                                                    :options [{:value "Report account"
                                                               :callback {:event ::events/report-account 
                                                                          :event-value (get-in toot [:account :id])}}
                                                              {:value "Block account"
                                                               :callback {:event ::events/block-account 
                                                                          :event-value (get-in toot [:account :id])}}]}])}
        [:i.icon.ion-ios-more]]])))

(defn- build-timeline->did-mount []
  (set!
    (.-onscroll (.querySelector js/document ".content"))
    (fn [event]
      (let [window-height (.-innerHeight js/window)
            content-height (.-scrollHeight (.querySelector js/document ".content"))
            reached-bottom? (= (.. event -target -scrollTop) (+ (- content-height window-height) 96))
            timeline @(rf/subscribe [::subscriptions/timeline])]
        (when reached-bottom?
          (if (= :notifications timeline)
            (rf/dispatch [::events/get-older-notifications])
            (rf/dispatch [::events/get-older-toots timeline])))
        (rf/dispatch [::events/set-scroll-from-top (.. event -target -scrollTop)])))))

(defn- build-timeline->render []
  (let [timeline @(rf/subscribe [::subscriptions/timeline])
        toots (cond
                (= :notifications timeline) @(rf/subscribe [::subscriptions/notifications])
                :else @(rf/subscribe [::subscriptions/toots timeline]))]
    (content
      (if-not (empty? toots)
        [:div.toots
         {:class (str (subs (str timeline) 1))}
         (for [toot toots]
           ^{:key toot} [:div.toot {:class (toot-class toot)}
                         (toot-heading toot)
                         (toot-content toot)
                         (toot-media toot)
                         (toot-actions toot)])]
        [:div.loading
         [:div.icon]]))))

(defn build-timeline []
  (r/create-class
    {:component-name "build-content"
     :component-did-mount (fn [] (build-timeline->did-mount))
     :component-did-update (fn [] (prn "update!"))
     :reagent-render (fn [] (build-timeline->render))}))

(defn build []
  [build-timeline])