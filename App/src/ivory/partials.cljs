(ns ivory.partials
  (:require [ivory.utils :as utils]))

(defn header [{:keys [title left-button right-button]}]
  [:div.header
   [:div.header-container
    [:div.header-main
     (when left-button
       [:div.left-action-btn
        {:on-click (get left-button :callback)}
        [:i.icon {:class (get left-button :icon)}]])
     (when title
       [:div.title title])
     (when right-button
       [:div.right-action-btn
        {:on-click (get right-button :callback)}
        [:i.icon {:class (get right-button :icon)}]])]]])

(defn footer [buttons]
  [:div.footer
   (for [btn buttons]
     ^{:key btn} [:div.btn
                   {:on-click (get btn :callback)
                    :class (get btn :class)}
                   [:i.icon {:class (get btn :icon)}]])])

(defn content [& content]
  (into [:div.content] content))

(defn confirm [{:keys [data]}]
  [:div.confirm-container
   [:div.confirm
    [:h2 (get data :title)]
    [:p (get data :description)]
    [:div.buttons
     [:div.action-button
      {:on-click (get data :action-button-callback)}
      (get data :action-button-label)]
     [:div.cancel-button
      {:on-click (get data :cancel-button-callback)}
      (get data :cancel-button-label)]]]])