# Tea Time

## Author

### Myles Nottingham
#### [GitHub](https://github.com/MylesNottingham) | [LinkedIn](https://www.linkedin.com/in/mylesnottingham/)

## Tech Stack

**Server:**
 - Ruby (language)
 - Rails API (framework)

## Installation

### Prerequisites
- Ensure Ruby is installed on your local machine
- Bundler is used for managing Ruby gem dependencies

### Clone the repository
``` 
git clone git@github.com:MylesNottingham/tea_time.git
cd tea_time
```

```
bundle install
```

### Database setup
run ``` rails db:{create,migrate,seed} ``` <br>

## Startup
- Service is configured to startup locally using port 3000
- Start service by running the command:
``` rails s ```

## Testing
- Run the test suite
``` bundle exec rspec spec ``` <br>


## API Reference

### Get Subscriptions for a Customer
GET '/api/v1/subscriptions'

Request:
```
{
  "customer_id": 1
}
```

Response:
```
{
  "data": [
    {
      "id": "1",
      "type": "subscription",
      "attributes": {
        "title": "White",
        "price": 7,
        "status": "active",
        "frequency": "monthly"
      }
    },
    {
      "id": "2",
      "type": "subscription",
      "attributes": {
        "title": "Green",
        "price": 6,
        "status": "cancelled",
        "frequency": "quarterly"
      }
    },
    {
      "id": "3",
      "type": "subscription",
      "attributes": {
        "title": "Black",
        "price": 6,
        "status": "cancelled",
        "frequency": "semiannually"
      }
    }
  ]
}
```

### Subscribe a Customer to a Tea Subscription
POST '/api/v1/subscriptions’

Request:
```
{
  "customer_id": 2,
  "subscription_id": 1,
  "frequency": 1
}
```

*frequency is optional, defaults to 0* 
<br>
*( 0 = monthly, 1 = quarterly, 2 = semiannually, 3 = annually )*

 Response:
```
{
  "data": {
    "id": "5",
    "type": "subscription",
    "attributes": {
      "title": "White",
      "price": 7,
      "status": "active",
      "frequency": "quarterly"
    }
  }
}
```

### Cancel a Subscription
PATCH '/api/v1/subscriptions/:id’

Request:
```
id = 5

{
  "status": 1
}
```

 Response:
```
{
  "data": {
    "id": "5",
    "type": "subscription",
    "attributes": {
      "title": "White",
      "price": 7,
      "status": "cancelled",
      "frequency": "quarterly"
    }
  }
}
```
