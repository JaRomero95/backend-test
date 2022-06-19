# Backend test

Reference: https://gist.github.com/francesc/33239117e4986459a9ff9f6ea64b4e80

## Stack

The project is developed with Ruby on Rails. Is a new project generated with the [CLI](https://guides.rubyonrails.org/command_line.html#rails-new).

## Additional libraries

I've added some libraries to the project.

- **kaminari:** for an easier pagination, not required in this project but I used to install it.
- **rspec-rails:** I replaced minitest with Rspec.
- **faker:** it helps me creating realistic fake data for testing.
- **annotate:** it adds automatically schema information to models. It's helpful and zero configuration.
- **rubocop-rails:** for consistency in coding-style during development.
- **simplecov:** to check current coverage of testing.

## Database

For simplicity, I worked with Sqlite in this project to avoid to setup another engine like PostgreSql.

## Schema decisions

The schema is formed by 4 models: Merchant, Shopper, Order and Disbursement. The first three follow the shape indicated in the challenge. There is only a difference, the type of the field amount in the Order model.

I think is better to work with integers when we need to handle money. We can avoid errors in operations with floats, and we can format easily the amount from cents to euros. Is better for internalization too, because other currencies don't have cents and it's unnecesary to persist amounts in float fields.

The schema of the Disbursement model is not fully indicated, but we know that it needs to register the amount and have a reference to the merchant. In this case I prefered to link this model with Order instead Merchant. 

## Performance
