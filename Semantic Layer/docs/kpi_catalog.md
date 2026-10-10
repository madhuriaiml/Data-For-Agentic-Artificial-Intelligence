# KPI Catalog

This document defines every metric in the Wanderbricks Semantic Layer — its formula, source, and business meaning.

---

## Revenue & Payments — `mv_revenue_metrics`

### Dimensions
| Name | Description |
| --- | --- |
| `payment_year` | Year of payment date |
| `payment_month` | Month of payment date (locale short month format) |
| `payment_method` | Payment method (credit_card, paypal, etc.) |

### Measures
| Measure | Formula | Business Meaning |
| --- | --- | --- |
| `total_revenue` | `SUM(amount)` | Total payment volume across all transactions |
| `total_payments` | `COUNT(1)` | Total number of payment records |
| `avg_payment_amount` | `AVG(amount)` | Average value per payment transaction |
| `successful_payments` | `COUNT(CASE WHEN is_successful = true THEN 1 END)` | Count of completed payments |
| `failed_payments` | `COUNT(CASE WHEN is_successful = false THEN 1 END)` | Count of failed/refunded payments |
| `payment_success_rate` | `successful_payments / total_payments` | Percentage of payments that completed successfully |

---

## Booking Analytics — `mv_booking_metrics`

### Dimensions
| Name | Description |
| --- | --- |
| `booking_year` | Year of check-in date |
| `booking_month` | Month of check-in date (locale short month format) |
| `booking_status` | Booking status (confirmed, cancelled, pending) |
| `property_type` | Property type from dim_properties (apartment, house, etc.) |
| `price_tier` | Price tier from dim_properties (Budget, Mid, Luxury, Premium) |

### Measures
| Measure | Formula | Business Meaning |
| --- | --- | --- |
| `total_bookings` | `COUNT(1)` | Total number of bookings |
| `avg_stay_duration` | `AVG(stay_duration_days)` | Average length of stay in days |
| `total_guests` | `SUM(guests_count)` | Total guests across all bookings |
| `total_booking_value` | `SUM(total_amount)` | Total value of all bookings |
| `avg_booking_value` | `AVG(total_amount)` | Average value per booking |

---

## Host Performance — `mv_host_performance`

### Dimensions
| Name | Description |
| --- | --- |
| `host_name` | Host's display name |
| `host_tier` | Tier from rating (Platinum, Gold, Silver, Bronze, Unrated) |
| `is_verified` | Whether host is verified |
| `is_active` | Whether host is currently active |
| `country` | Host's country |
| `rating` | Host's rating score (1-5) |

### Measures
| Measure | Formula | Business Meaning |
| --- | --- | --- |
| `total_properties` | `SUM(total_properties)` | Total properties listed by host |
| `avg_base_price` | `AVG(avg_base_price)` | Average nightly base price across host's properties |
| `total_max_capacity` | `SUM(total_max_capacity)` | Total guest capacity across all properties |
| `total_employees` | `SUM(total_employees)` | Total employees working for host |
| `active_employees` | `SUM(active_employees)` | Currently active employees |
| `total_bookings` | `SUM(total_bookings)` | Total bookings across host's properties |
| `total_booking_revenue` | `SUM(total_booking_revenue)` | Total revenue from host's bookings |
| `avg_booking_value` | `AVG(avg_booking_value)` | Average booking value for host's properties |

---

## User Analytics — `mv_user_analytics`

### Dimensions
| Name | Description |
| --- | --- |
| `signup_year` | Year of account creation |
| `signup_month` | Month of account creation (locale short month format) |
| `user_segment` | Business or individual |
| `country` | User's country |
| `is_business` | Whether user is a business account |
| `is_repeat_user` | Whether user has more than 1 booking |

### Measures
| Measure | Formula | Business Meaning |
| --- | --- | --- |
| `new_users` | `COUNT(1)` | Total users in the group |
| `new_business_users` | `COUNT(CASE WHEN is_business = true THEN 1 END)` | New business user signups |
| `new_individual_users` | `COUNT(CASE WHEN is_business = false THEN 1 END)` | New individual user signups |
| `business_pct` | `new_business_users / new_users` | Percentage of signups that are business accounts |
| `total_repeat_users` | `COUNT(CASE WHEN is_repeat_user = true THEN 1 END)` | Users with 2+ bookings |
| `total_users_with_bookings` | `COUNT(CASE WHEN booking_count > 0 THEN 1 END)` | Users who have made at least 1 booking |
| `repeat_booking_rate` | `total_repeat_users / total_users_with_bookings` | % of booking users who booked more than once |

---

## Executive Dashboard — `vw_executive_dashboard`

A standard SQL view combining monthly KPIs across all domains:

| Column | Source | Definition |
| --- | --- | --- |
| `year` | Payment/booking/signup year | Calendar year |
| `month` | Payment/booking/signup month | Calendar month |
| `total_revenue` | fact_payments | SUM(amount) WHERE is_successful = true |
| `total_payments` | fact_payments | COUNT(*) WHERE is_successful = true |
| `total_bookings` | fact_bookings | COUNT(*) WHERE status = 'confirmed' |
| `total_booking_value` | fact_bookings | SUM(total_amount) WHERE status = 'confirmed' |
| `avg_stay_days` | fact_bookings | AVG(stay_duration_days) WHERE status = 'confirmed' |
| `new_users` | dim_users | COUNT(*) by signup month |
| `active_hosts` | dim_hosts | COUNT(DISTINCT host_id) WHERE is_active = true |