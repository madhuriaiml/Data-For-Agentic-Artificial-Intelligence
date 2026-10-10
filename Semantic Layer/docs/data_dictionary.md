# Data Dictionary

## Source Tables — `samples.wanderbricks`

### `users`
| Column | Type | Description |
| --- | --- | --- |
| `user_id` | BIGINT | PK — Unique user identifier |
| `email` | STRING | User email address |
| `name` | STRING | User full name |
| `country` | STRING | Country of residence |
| `user_type` | STRING | Type: individual or business |
| `created_at` | TIMESTAMP | Account creation date |
| `is_business` | BOOLEAN | Is business account |
| `company_name` | STRING | Company name (if business) |

### `hosts`
| Column | Type | Description |
| --- | --- | --- |
| `host_id` | BIGINT | PK — Unique host identifier |
| `name` | STRING | Host full name |
| `email` | STRING | Host email |
| `phone` | STRING | Host phone |
| `is_verified` | BOOLEAN | Verification status |
| `is_active` | BOOLEAN | Active status |
| `rating` | DOUBLE | Host rating (1-5) |
| `country` | STRING | Country |
| `joined_at` | TIMESTAMP | Host join date |

### `properties`
| Column | Type | Description |
| --- | --- | --- |
| `property_id` | BIGINT | PK — Unique property identifier |
| `host_id` | BIGINT | FK → hosts.host_id |
| `destination_id` | BIGINT | Destination/location identifier |
| `title` | STRING | Property listing title |
| `description` | STRING | Property description |
| `base_price` | DOUBLE | Nightly base price (USD) |
| `property_type` | STRING | Type: apartment, house, etc. |
| `max_guests` | INT | Maximum occupancy |
| `bedrooms` | INT | Number of bedrooms |
| `bathrooms` | INT | Number of bathrooms |
| `property_latitude` | DOUBLE | GPS latitude |
| `property_longitude` | DOUBLE | GPS longitude |
| `created_at` | TIMESTAMP | Listing creation date |

### `bookings`
| Column | Type | Description |
| --- | --- | --- |
| `booking_id` | BIGINT | PK — Unique booking identifier |
| `user_id` | BIGINT | FK → users.user_id |
| `property_id` | BIGINT | FK → properties.property_id |
| `check_in` | DATE | Check-in date |
| `check_out` | DATE | Check-out date |
| `guests_count` | INT | Number of guests |
| `total_amount` | DOUBLE | Total booking amount (USD) |
| `status` | STRING | Status: confirmed, cancelled, pending |
| `created_at` | TIMESTAMP | Booking creation date |
| `updated_at` | TIMESTAMP | Last update date |

### `payments`
| Column | Type | Description |
| --- | --- | --- |
| `payment_id` | BIGINT | PK — Unique payment identifier |
| `booking_id` | BIGINT | FK → bookings.booking_id |
| `amount` | DOUBLE | Payment amount (USD) |
| `payment_method` | STRING | Method: credit_card, paypal, etc. |
| `status` | STRING | Status: completed, refunded, failed |
| `payment_date` | TIMESTAMP | Payment date |

### `employees`
| Column | Type | Description |
| --- | --- | --- |
| `employee_id` | BIGINT | PK — Unique employee identifier |
| `host_id` | BIGINT | FK → hosts.host_id |
| `name` | STRING | Employee name |
| `role` | STRING | Job role |
| `email` | STRING | Employee email |
| `phone` | STRING | Employee phone |
| `country` | STRING | Country |
| `joined_at` | TIMESTAMP | Join date |
| `end_service_date` | TIMESTAMP | End of service (nullable) |
| `is_currently_employed` | BOOLEAN | Currently employed |

---

## Silver Layer — Derived Columns

### `silver.users` — Derived Fields
| Column | Logic |
| --- | --- |
| `user_segment` | CASE: is_business=true → 'business', false → 'individual', else → user_type |
| `has_null_email` | true if email is NULL or empty |

### `silver.hosts` — Derived Fields
| Column | Logic |
| --- | --- |
| `host_tier` | rating >= 4.5 → 'Platinum', >= 4.0 → 'Gold', >= 3.0 → 'Silver', >= 1.0 → 'Bronze', else → 'Unrated' |
| `has_null_email` | true if email is NULL or empty |
| `has_null_phone` | true if phone is NULL or empty |

### `silver.properties` — Derived Fields
| Column | Logic |
| --- | --- |
| `price_tier` | base_price >= 500 → 'Premium', >= 200 → 'Luxury', >= 100 → 'Mid', >= 0 → 'Budget', else → 'Unknown' |
| `has_invalid_lat` | true if latitude is NULL or out of [-90, 90] |
| `has_invalid_long` | true if longitude is NULL or out of [-180, 180] |

### `silver.bookings` — Derived Fields
| Column | Logic |
| --- | --- |
| `stay_duration_days` | DATEDIFF(check_out, check_in) |
| `booking_month` | DATE_TRUNC('month', check_in) |
| `booking_year` | YEAR(check_in) |
| `has_invalid_dates` | true if check_out <= check_in |
| `has_invalid_guest_count` | true if guests_count is NULL or <= 0 |

### `silver.payments` — Derived Fields
| Column | Logic |
| --- | --- |
| `is_successful` | true if status = 'completed' |
| `payment_month` | DATE_TRUNC('month', payment_date) |
| `payment_year` | YEAR(payment_date) |
| `has_invalid_amount` | true if amount is NULL or <= 0 |

### `silver.employees` — Derived Fields
| Column | Logic |
| --- | --- |
| `employment_status` | is_currently_employed=false OR end_service_date NOT NULL → 'inactive', else → 'active' |
| `has_null_email` | true if email is NULL or empty |

---

## Gold Layer — Star Schema

### Dimensions
| View | Grain | Key Columns |
| --- | --- | --- |
| `dim_users` | One row per user | `user_id` (PK), `user_segment`, `signup_year`, `signup_month` |
| `dim_hosts` | One row per host | `host_id` (PK), `host_tier`, `join_year`, `join_month` |
| `dim_properties` | One row per property | `property_id` (PK), `host_id` (FK), `price_tier`, `listed_year` |
| `dim_employees` | One row per employee | `employee_id` (PK), `host_id` (FK), `employment_status` |
| `dim_date` | One row per day | `date_id` (PK), `year`, `month`, `quarter`, `season`, `year_quarter` |

### Facts
| View | Grain | Key Columns | Measures |
| --- | --- | --- | --- |
| `fact_bookings` | One row per booking | `booking_id` (PK), `user_id`, `property_id`, `host_id` | `total_amount`, `stay_duration_days`, `guests_count` |
| `fact_payments` | One row per payment | `payment_id` (PK), `booking_id`, `user_id`, `property_id`, `host_id` | `amount`, `is_successful` |