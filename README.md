# Backend test

https://gist.github.com/francesc/33239117e4986459a9ff9f6ea64b4e80

## Stack

The project is developed with Ruby on Rails. Is a new project generated with the [CLI](https://guides.rubyonrails.org/command_line.html#rails-new).

## Additional libraries

I've added some libraries to the project:

- **kaminari:** for easier pagination, not required in this project but I used to install it.
- **rspec-rails:** I replaced minitest with Rspec.
- **faker:** it helps me create realistic fake data for testing.
- **annotate:** it adds automatically schema information to models. It's helpful and zero configuration.
- **rubocop-rails:** to maintain consistency in coding-style during development.
- **simplecov:** to check current coverage of tests.

## Database

For simplicity, I worked with Sqlite in this project to avoid to setting up another engine like PostgreSql.

## Setup

It is a basic Rails application so it does not require much configuration. I didn't add a docker file so the setup has to be manual.

Steps:
- Install Ruby 3.1.2
- Install gem bundler 2.3.15
- Install sqlite system dependencies (depends on the S.O.):
  - sudo apt-get install sqlite3 libsqlite3-dev
  - brew install sqlite3
  - sudo yum install sqlite3 sqlite3-devel
- Clone the repo
- Run bundle install
- Run bundle exec rails db:setup (it loads seed data too)
- Run bundle exec rails server
- You can access in development mode to http://127.0.0.1:3000/disbursements

## Schema decisions

The schema is formed by 4 models: Merchant, Shopper, Order and Disbursement. The first three follow the shape indicated in the challenge. There is only a difference: the type of the field amount in the Order model. It's Integer instead of Float/Decimal.

I think is better to work with integers when we need to handle money. We can avoid errors in operations with floats, and we can format the amount easily from cents to euros. Is better for internalization too, because other currencies don't have cents and it's unnecessary to persist amounts in float fields. Another useful trick to avoid math float errors is to work with the BigDecimal class. Rails automatically transform fields typed as "decimal" to BigDecimal so it's safe to work with it. In this project, I use the `.to_d` method instead of `.to_f` when I need to make an operation that can result in decimals.

The schema of the Disbursement model is not fully indicated in the challenge, but we know that it needs to register the amount and have a reference to the merchant. In this case, I prefer to link this model with Order instead Merchant. Following the database normalization rules, it is redundant to link both Merchant and Order to Disbursement with our schema, and I think is good to know what is the origin of the disbursement. We'll obtain the relationship between Disbursement and Merchant through the orders.

The field "fee" is not in the schema, because is calculated from the amount of the order based on rules. If fee rules change over time, we can obtain the fee because the Disbursement references the order that has the full paid amount. It can be useful to register values like this in the schema, no matter if it breaks normalization, it is a field easy to control and can improve performance if we need to print a full report of disbursements with fee data, but this is not necessary for this challenge.

## Background tasks

As the requirements specified, the disbursements generator should be able to run in the background, so I created both, a job and a task.

I did not install an ActiveJob adapter, so the default adapter is used here. I usually work with Sidekiq in production.

In this scenario, I think that the only thing required is the task because if the requirement is to execute it periodically on Mondays, the best option is to schedule a cronjob in the system, so to make the service executable from the command line a task is the way to do it.

But anyways I created the Job, could be useful to have that option, it can be enqueued from a controller with a parametrized date.

Both job and task are very simple and are only a wrapper to the generator service. The job handles the conversion between the date string and the date expected by the service. This is important because Date objects can generate problems with serialization. Queue adapters like Sidekiq strongly recommend sending only plain data to jobs.

Jobs and tasks should be always only a wrapper and the only logic they need is parameters conversion if it is required. Delegates always logic in other classes permits us to reuse that code in other places.

The task doesn't handle the conversion, instead, it triggers the job that handle the CLI argument.

If the task is executed without arguments, it'll take a day from the previous week. This is the default work mode for this job, when the task is executed on Monday, it should generate disbursements for the previous week.

## Import data

For importation purposes, I've created an importer class that can handle the CSV files and insert all data in the correspondent model. This class is generic and can work with the three models that we need to import for this challenge.

The class can receive a list of formatters for fields so it's easy to process special values, we can make the conversion from decimal to integer in the Order model. We can create formatters also for things like import dates from strings, but in this case, they are correctly parsed by ActiveRecord without additional work.

It's easy to add the code for the JSON files instead of CSV. The importer class follows the dependency inversion principle, so it does not rely on the CsvReader class, instead it can receive another reader class. Implementing a JSON file parser could take a few minutes only, the same for other file formats.

If we create a second file parser, I'd create a shared example to test the reader class interface for both services. If CsvReader and JsonReader are going to share the same interface, they need to respond to the same tests. Shared examples are the best way to assure interfaces in Ruby with Rspec.

## Performance

API has only one index action so there are not many performance decisions to make. The critical point in this exercise is the importation of resources and the generation of disbursements.

In both cases, I chose the massive insertion in the database instead of going one by one validating and saving. It is not the official recommendation but it is indispensable if we do batch operations like these.

The importer used the `insert_all` clause from the beginning while for the DisbursementGenerator I initially tried to use a normal `save` with validation. But in the first test with data, I discovered that it is not fast enough for this volume of data, so I changed to another batch action skipping validations.

I think that in the first approximation is better to create code correct and legible than performant, avoiding problems with premature optimization, following the rule "Code First, Optimize Later". This is not always true, because there are situations where we know from the beginning that we need to develop an optimal solution, but when is possible I prefer to prioritize simplicity over performance because is easier to maintain and save money and time in the long run.

## The Rails way

In huge projects, Rails can become a problem, in special if we talk about ActiveRecord. If we use the provided tools of Rails in the way that they are designed, we can create an application hard to maintain and change. Models start to accumulate logic and trigger callbacks, and any complex action forces us to skip model validations if we don't want to waste a lot of time and resources. We start to spread calls to the database through all the code, in part thanks to the facilities of ActiveRecord for doing this.

In this project, I followed the common Rails way, but in a real scenario, I'd try to avoid some practices. Additional services can handle validations instead of the model and could handle actions like creating/updating/deleting resources by wrapping ActiveRecord actions. Model hooks become a problem for performance and readability in the long run so I'd trigger that actions in services in a more declarative way.

Other services can act as repositories, allowing us to group and reuse complex queries, or even use low-level queries in a transparent way, returning model instances if it is necessary, but decoupling the data access from the rest of the application.

## Testing strategy

As I mentioned before, I used Rspec for testing. These are some decisions I took:

- **Before all vs Before each/let:** I prefer to use before_each/let and to have a clean scenario before each test instead of before_all, just like the Rspec guidelines recommend. I know it is not the best option for having a fast test suite, but maintaining tests with data that can be mutated between examples become a big maintainability problem. I'd change to before_all only for tests that take too long.
- **Fake data:** I prefer to use factories than complex seeds when required. Only people with experience in the project can work comfortably with large seeds, and they are hard to maintain for all. In some cases, if it is hard to create a minimum scenario for tests and it requires a lot of setup creating resources (case common in integration/end-to-end tests) we can use a combination of both: a seed with indispensable data + factories for additional scenario-related data.
- **Unit tests:** a test that queries and persists data in a real database can't be called a unit test. However, thanks to or because of Rails, it is easier to test a lot of things using a real database with real data persisted. A lot of things in our code depend on ActiveRecord calls and the methods of this API that we usually use are wide. The setup should be huge to mock all the methods that we can use from a simple model in any part of our application.
- **Model tests:** I try to avoid some common tests in the Rails community for models, like tests of fields, associations and rails validations. Fields and associations are usually redundant and don't test any feature. If something is broken, other tests should fail, not these. Same for validation tests that are a mirror of rails common validations. I like to test validation without thinking if it is a custom validation with available RSpec helpers or not, focusing only on the scenario and the result. I need to add more tests for filters but I didn't finish that part.
- **Model importer tests:** in this service we have unit tests that mock the injected dependencies without problems.
- **Services tests:** while FeeCalculator is a simple class and can be tested easily with unit tests, for DisbursementsGenerator I preferred to use persisted data to be sure about the reliability of this test, but trying to avoid big setups.
- **Controller tests:** I did not complete this part. For controllers with common actions I usually develop shared examples that test these features of the action. *it_behaves_like 'filterable action'*, *it_behaves_like 'authenticated action'*, *it_behaves_like 'sortable action'*. I try to mock services invoked during the controller action and I make assertions in arguments sent to those services when it is possible.

### Coverage

It is close to 100%, not reached because I left controller and disbursement filters without testing, but it should be 100% if I would finish the work.

Reaching 100% coverage is not my objective in a project, so I'm not obsessed with making tests of configuration files and not important things like that, but I test every line of the new code of the application, there is no other way with TDD. If I have a non-tested line, always I review it because maybe they don't need to exist.

## Seed data

The file `db/seeds.rb` is ready to import all the received data for this challenge and to generate the disbursements. It is not tested because it is only a seed for fake data used in development. In some cases is useful to add tests to the seed if it becomes complex, but usually, it is not a big problem to update the seed if something strange happens in a development environment.

## Resource representations

A way to handle resource representations in the API is not implemented. The only created action rests in the default serialization which is enough for this project.

## Example

http://127.0.0.1:3000/disbursements?page[number]=1&filter[merchant_id]=9&filter[date_week]=01/01/2018

```json
{
   "data":[
      {
         "id":3,
         "amount":18359,
         "order_id":4,
         "created_at":"2022-06-19T21:28:48.174Z",
         "updated_at":"2022-06-19T21:28:48.174Z"
      },
      {
         "id":42,
         "amount":20559,
         "order_id":50,
         "created_at":"2022-06-19T21:28:48.174Z",
         "updated_at":"2022-06-19T21:28:48.174Z"
      },
      {
         "id":59,
         "amount":21405,
         "order_id":71,
         "created_at":"2022-06-19T21:28:48.174Z",
         "updated_at":"2022-06-19T21:28:48.174Z"
      },
      {
         "id":67,
         "amount":7547,
         "order_id":80,
         "created_at":"2022-06-19T21:28:48.174Z",
         "updated_at":"2022-06-19T21:28:48.174Z"
      },
      {
         "id":69,
         "amount":34034,
         "order_id":82,
         "created_at":"2022-06-19T21:28:48.174Z",
         "updated_at":"2022-06-19T21:28:48.174Z"
      }
   ],
   "metadata":{
      "page":1,
      "page_count":5,
      "per_page":20,
      "total_count":5
   }
}
```
