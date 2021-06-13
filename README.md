# ExBanking

ExBanking is a simple impementation of a ledger using pure GenServer behaviour

## Business Rules

* Money amount of any currency should not be negative.
* Application should provide 2 decimal precision of money amount for any currency.
* Amount of money incoming to the system should be equal to amount of money inside the system + amount of withdraws (money should not appear or disappear accidentally).
* User and currency type is any string. Case sensitive. New currencies / users can be added dynamically in runtime. In the application, there should be a special public function (described below) for creating users. Currencies should be created automatically (if needed).

## API Reference

Requirements for public functions provided by ExBanking module. Any function should return success result or error result.

`@spec create_user(user :: String.t) :: :ok | {:error, :wrong_arguments | :user_already_exists}`

* Function creates new user in the system
* New user has zero balance of any currency

`@spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}`

* Increases user’s balance in given currency by amount value
* Returns new_balance of the user in given format

`@spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}`

* Decreases user’s balance in given currency by amount value
* Returns new_balance of the user in given format

`@spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}`

* Returns balance of the user in given format

`@spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}`

* Decreases from_user’s balance in given currency by amount value
* Increases to_user’s balance in given currency by amount value
* Returns balance of from_user and to_user in given format

## Performance

* In every single moment of time the system should handle 10 or less operations for every individual user (user is a string passed as the first argument to API functions). If there is any new operation for this user and he/she still has 10 operations in pending state - new operation for this user should immediately return too_many_requests_to_user error until number of requests for this user decreases < 10
* The system should be able to handle requests for different users in the same moment of time
* Requests for user A should not affect to performance of requests to user B (maybe except send function when both A and B users are involved in the request)


