(ns ivory.subscriptions
  (:require [re-frame.core :as rf]
            [ivory.utils :as utils :refer [find-in-collection]]))

(rf/reg-sub
  ::view
  (fn [db _]
    (get db :view)))

(rf/reg-sub
  ::toots
  (fn [db [_ timeline]]
    (get-in db [:toots timeline])))

(rf/reg-sub
  ::notifications
  (fn [db _]
    (get db :notifications)))

(rf/reg-sub
  ::tooting?
  (fn [db _]
    (get db :tooting?)))

(rf/reg-sub
  ::reply-to-toot
  (fn [db _]
    (get db :reply-to-toot)))

(rf/reg-sub
  ::confirm-dialog
  (fn [db _]
    (let [confirm-dialog-data (get db :confirm-dialog-data)]
      (if-not (empty? confirm-dialog-data)
        confirm-dialog-data
        nil))))

(rf/reg-sub
  ::timeline
  (fn [db _]
    (get db :timeline)))

(rf/reg-sub
  ::instance-url
  (fn [db _]
    (get db :instance-url)))

(rf/reg-sub
  ::scroll-from-top
  (fn [db _]
    (get db :scroll-from-top)))

(rf/reg-sub
  ::screen-width
  (fn [db _]
    (get db :screen-width)))

(rf/reg-sub
  ::mobile-device?
  (fn [db _]
    (< (get db :screen-width) 650)))

(rf/reg-sub
  ::pop
  (fn [db _]
    (get db :pop)))