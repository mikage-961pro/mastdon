(ns ivory.common.composer
  (:require [reagent.core :as r]
            [re-frame.core :as rf]
            [ivory.subscriptions :as subscriptions]
            [ivory.utils :as utils]))

(def composer-state (r/atom {:content nil}))

(defn- build-composer []
  (let [tooting? @(rf/subscribe [::subscriptions/tooting?])
        reply-to-toot @(rf/subscribe [::subscriptions/reply-to-toot])]
    (when tooting?
      [:div.composer
       {:class (when reply-to-toot "in-reply-to")}
       (when reply-to-toot
         [:div.in-reply-to-toot
          [:div.acct (get-in reply-to-toot [:account :display_name])]
          [:div.text {:dangerouslySetInnerHTML {:__html (get reply-to-toot :content)}}]])
       [:textarea#composer-area
        {:on-input #(swap! composer-state assoc :content (-> % .-target .-value))
         :placeholder "Tap here to compose awesomeness ..."
         :default-value (when reply-to-toot
                          (str "@" (get-in reply-to-toot [:account :acct]) " "))}]])))

(defn build []
  (build-composer))