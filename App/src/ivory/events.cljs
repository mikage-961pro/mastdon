(ns ivory.events
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require [re-frame.core :as rf]
            [cljs-http.client :as http]
            [cljs.core.async :refer [<!]]
            [ivory.utils :as utils]
            [ivory.subscriptions :as subscriptions]
            [reagent.core :as r]))

(def initial-data {:view :toots
                   :confirm-dialog-data {}
                   :scroll-from-top 0
                   :screen-width 0
                   :instance-url nil
                   :tooting? nil
                   :access-token nil
                   :toot nil
                   :reply-to-toot nil
                   :pop nil
                   :timeline :home
                   :toots {:home []
                           :local []
                           :federated []}
                   :notifications []})

(rf/reg-event-db
  ::initialize
  (fn [_ _]
    initial-data))

(rf/reg-event-fx
  ::initialize-data
  (fn [cofx _]
    (rf/dispatch [::set-instance-url (.getAttribute js/document.documentElement "url")])
    (rf/dispatch [::set-access-token (.getAttribute js/document.documentElement "token")])
    (rf/dispatch [::get-toots :home])
    (rf/dispatch [::set-view :timelines])
    {}))

(rf/reg-event-fx
  ::set-view
  (fn [cofx [_ view]]
    {:db (assoc (get cofx :db) :view view)}))

(rf/reg-event-fx
  ::set-confirm-dialog-data
  (fn [cofx [_ data]]
    {:db (assoc (get cofx :db) :confirm-dialog-data data)}))

(rf/reg-event-fx
  ::set-scroll-from-top
  (fn [cofx [_ value]]
    {:db (assoc (get cofx :db) :scroll-from-top value)}))

(rf/reg-event-fx
  ::set-screen-width
  (fn [cofx [_ value]]
    {:db (assoc (get cofx :db) :screen-width value)}))

(rf/reg-event-fx
  ::set-instance-url
  (fn [cofx [_ url]]
    {:db (assoc (get cofx :db) :instance-url url)}))

(rf/reg-event-fx
  ::set-timeline
  (fn [cofx [_ timeline]]
    (.scrollTo (js/document.querySelector ".content") 0 0)
    {:db (assoc (get cofx :db) :timeline timeline)}))

(rf/reg-event-fx
  ::signout
  (fn [cofx _]
    {:db initial-data
     :dispatch [::set-view :signin]}))

(rf/reg-event-fx
  ::set-access-token
  (fn [cofx [_ token]]
    {:db (assoc (get cofx :db) :access-token token)}))

(rf/reg-event-fx
  ::set-toots
  (fn [cofx [_ timeline toots]]
    {:db (assoc-in (get cofx :db) [:toots timeline] toots)}))

(rf/reg-event-fx
  ::set-notifications
  (fn [cofx [_ notifications]]
    {:db (assoc (get cofx :db) :notifications notifications)}))

(rf/reg-event-fx
  ::set-pop
  (fn [cofx [_ pop]]
    {:db (assoc (get cofx :db) :pop pop)}))

(rf/reg-event-fx
  ::get-toots
  (fn [cofx [_ timeline]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          timeline-raw (cond
                         (or (= :local timeline)
                             (= :federated timeline)) "public"
                         :else (subs (str timeline) 1))
          query-params (cond (= :local timeline) {:local true}
                             (= :federated timeline) {}
                             :else {})]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/timelines/" timeline-raw)
                                       {:with-credentials? false
                                        :query-params query-params
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (rf/dispatch [::set-toots timeline (get response :body)])))
      {})))

(rf/reg-event-fx
  ::get-newer-toots
  (fn [cofx [_ timeline]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          toots (get-in cofx [:db :toots timeline])
          since-id (get (first toots) :id)
          timeline-raw (cond
                         (or (= :local timeline)
                             (= :federated timeline)) "public"
                         :else (subs (str timeline) 1))
          query-params (cond (= :local timeline) {:local true
                                                  :since_id since-id}
                             :else {:since_id since-id})]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/timelines/" timeline-raw)
                                       {:with-credentials? false
                                        :query-params query-params
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (rf/dispatch [::set-toots timeline (concat toots (get response :body))])))
      {})))

(rf/reg-event-fx
  ::get-older-toots
  (fn [cofx [_ timeline]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          toots (get-in cofx [:db :toots timeline])
          max-id (get (last toots) :id)
          timeline-raw (cond
                         (or (= :local timeline)
                             (= :federated timeline)) "public"
                         :else (subs (str timeline) 1))
          query-params (cond (= :local timeline) {:local true
                                                  :max_id max-id}
                             :else {:max_id max-id})]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/timelines/" timeline-raw)
                                       {:with-credentials? false
                                        :query-params query-params
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (rf/dispatch [::set-toots timeline (concat toots (get response :body))])))
      {})))

(rf/reg-event-fx
  ::set-newest-notification-id-in-store
  (fn [cofx [_ id]]
    (js/webkit.messageHandlers.ivorySetNewestNotificationId.postMessage (str id))))
    
(rf/reg-event-fx
  ::get-notifications
  (fn [cofx [_ timeline]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/notifications")
                                       {:with-credentials? false
                                        :query-params {}
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (when-not (empty? (get response :body))
              (rf/dispatch [::set-newest-notification-id-in-store (get (first (get response :body)) :id)])
              (rf/dispatch [::set-notifications (get response :body)]))))
      {})))

(rf/reg-event-fx
  ::get-newer-notifications
  (fn [cofx _]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          notifications (get-in cofx [:db :notifications])
          since-id (get (first notifications) :id)]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/notifications")
                                       {:with-credentials? false
                                        :query-params {:since_id since-id}
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (when-not (empty? (get response :body))
              (rf/dispatch [::set-newest-notification-id-in-store (get (first (get response :body)) :id)])
              (rf/dispatch [::set-notifications (concat (get response :body) notifications)]))))
      {})))

(rf/reg-event-fx
  ::get-older-notifications
  (fn [cofx _]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          notifications (get-in cofx [:db :notifications])
          max-id (get (last notifications) :id)]
      (go (let [response (<! (http/get (str "https://" url "/api/v1/notifications")
                                       {:with-credentials? false
                                        :query-params {:max_id max-id}
                                        :headers {"Authorization" (str "Bearer " token)}}))]
            (rf/dispatch [::set-notifications (concat notifications (get response :body))])))
      {})))

(rf/reg-event-fx
  ::toot
  (fn [cofx _]
    (if (get-in cofx [:db :tooting?])
      {:db (assoc (get cofx :db) :tooting? nil)}
      {:db (assoc (get cofx :db) :tooting? true)})))

(rf/reg-event-fx
  ::set-reply-to-toot
  (fn [cofx [_ toot]]
    {:db (assoc (get cofx :db) :reply-to-toot toot)}))

(rf/reg-event-fx
  ::post-toot
  (fn [cofx [_ toot]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          reply-to-toot (get-in cofx [:db :reply-to-toot])
          reply-to-id (get reply-to-toot :id)]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/statuses")
                                        {:with-credentials? false
                                         :form-params {:status toot
                                                       :visibility "public"
                                                       :in_reply_to_id reply-to-id}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      {:db (assoc (get cofx :db) :tooting? nil)
       :dispatch [::set-reply-to-toot nil]})))

(rf/reg-event-fx
  ::favourite-toot
  (fn [cofx [_ toot]]
    (let [id (get toot :id)
          url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          timeline (get-in cofx [:db :timeline])
          toots (if (= :notifications timeline)
                  (get-in cofx [:db :notifications])
                  (get-in cofx [:db :toots timeline]))
          updated-toots (reduce (fn [toots toot]
                                  (if (empty? (get toot :reblog))
                                    (conj toots (if (= (get toot :id) id)
                                                  (assoc toot :favourited true)
                                                  toot))
                                    (conj toots (if (= (get-in toot [:reblog :id]) id)
                                                  (assoc-in toot [:reblog :favourited] true)
                                                  toot))))
                                []
                                toots)]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/statuses/" id "/favourite")
                                        {:with-credentials? false
                                         :form-params {}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      (if (= :notifications timeline)
        {:db (assoc (get cofx :db) :notifications updated-toots)}
        {:db (assoc-in (get cofx :db) [:toots timeline] updated-toots)}))))

(rf/reg-event-fx
  ::unfavourite-toot
  (fn [cofx [_ toot]]
    (let [id (get toot :id)
          url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          timeline (get-in cofx [:db :timeline])
          toots (if (= :notifications timeline)
                  (get-in cofx [:db :notifications])
                  (get-in cofx [:db :toots timeline]))
          updated-toots (reduce (fn [toots toot]
                                  (if (empty? (get toot :reblog))
                                    (conj toots (if (= (get toot :id) id)
                                                  (assoc toot :favourited false)
                                                  toot))
                                    (conj toots (if (= (get-in toot [:reblog :id]) id)
                                                  (assoc-in toot [:reblog :favourited] false)
                                                  toot))))
                                []
                                toots)]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/statuses/" id "/unfavourite")
                                        {:with-credentials? false
                                         :form-params {}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      (if (= :notifications timeline)
        {:db (assoc (get cofx :db) :notifications updated-toots)}
        {:db (assoc-in (get cofx :db) [:toots timeline] updated-toots)}))))

(rf/reg-event-fx
  ::boost-toot
  (fn [cofx [_ toot]]
    (let [id (get toot :id)
          url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          timeline (get-in cofx [:db :timeline])
          toots (if (= :notifications timeline)
                  (get-in cofx [:db :notifications])
                  (get-in cofx [:db :toots timeline]))
          updated-toots (reduce (fn [toots toot]
                                  (if (empty? (get toot :reblog))
                                    (conj toots (if (= (get toot :id) id)
                                                  (assoc toot :reblogged true)
                                                  toot))
                                    (conj toots (if (= (get-in toot [:reblog :id]) id)
                                                  (assoc-in toot [:reblog :reblogged] true)
                                                  toot))))
                                []
                                toots)]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/statuses/" id "/reblog")
                                        {:with-credentials? false
                                         :form-params {}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      (if (= :notifications timeline)
        {:db (assoc (get cofx :db) :notifications updated-toots)}
        {:db (assoc-in (get cofx :db) [:toots timeline] updated-toots)}))))

(rf/reg-event-fx
  ::unboost-toot
  (fn [cofx [_ toot]]
    (let [id (get toot :id)
          url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])
          timeline (get-in cofx [:db :timeline])
          toots (if (= :notifications timeline)
                  (get-in cofx [:db :notifications])
                  (get-in cofx [:db :toots timeline]))
          updated-toots (reduce (fn [toots toot]
                                  (if (empty? (get toot :reblog))
                                    (conj toots (if (= (get toot :id) id)
                                                  (assoc toot :reblogged false)
                                                  toot))
                                    (conj toots (if (= (get-in toot [:reblog :id]) id)
                                                  (assoc-in toot [:reblog :reblogged] false)
                                                  toot))))
                                []
                                toots)]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/statuses/" id "/unreblog")
                                        {:with-credentials? false
                                         :form-params {}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      (if (= :notifications timeline)
        {:db (assoc (get cofx :db) :notifications updated-toots)}
        {:db (assoc-in (get cofx :db) [:toots timeline] updated-toots)}))))

(rf/reg-event-fx
  ::report-account
  (fn [cofx [_ id]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/reports")
                                        {:with-credentials? false
                                         :form-params {:account_id id}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      {:db (assoc (get cofx :db) :pop nil)
       :dispatch [::set-pop {:type "alert"
                             :options {:title "Account reported!"
                                       :description "You have successfuly reported the account in question. It will be reviewed by the moderators of this instance."}}]})))

(rf/reg-event-fx
  ::block-account
  (fn [cofx [_ id]]
    (let [url (get-in cofx [:db :instance-url])
          token (get-in cofx [:db :access-token])]
      (go (let [response (<! (http/post (str "https://" url "/api/v1/accounts/" id "/block")
                                        {:with-credentials? false
                                         :form-params {}
                                         :headers {"Authorization" (str "Bearer " token)}}))]))
      {:db (assoc (get cofx :db) :pop nil)
       :dispatch [::set-pop {:type "alert"
                             :options {:title "Account blocked"
                                       :description "You have successfully blocked the account in question. It will no longer show up in your timelines."}}]})))
