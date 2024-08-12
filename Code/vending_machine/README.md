## Version

This project is currently at version `1.0.0`.

# Vending Machine

This is a Ruby implementation of a vending machine with a focus on Object-Oriented Programming (OOP) principles.

## Features

- Handle multiple products with different prices
- Manage money transactions and provide change
- Track inventory and manage expiration dates

## Structure

- `lib/`
  - `vending_machine.rb` - The main class for the vending machine.
  - `money_handler.rb` - Handles money insertion, change-making, and refunds.
  - `inventory.rb` - Manages product inventory.
  - `product.rb` - Represents a product.
  - `vending_machine/version.rb` - Contains version information.
- `bin/`
  - `console` - A command-line interface for interacting with the vending machine.
  - `console-irb` - A command-line IRB interface for interacting with the vending machine.
- `spec/`
  - `vending_machine_spec.rb` - Tests for the `VendingMachine` class.
  - `money_handler_spec.rb` - Tests for the `MoneyHandler` class.
  - `inventory_spec.rb` - Tests for the `Inventory` class.
  - `product_spec.rb` - Tests for the `Product` class.
  - `spec_helper.rb` - Sets up the testing environment.
- `Gemfile` - Specifies gem dependencies.
- `Rakefile` - Defines Rake tasks for testing.
- `README.md` - Project documentation.


## Getting Started
1. Clone the repository.
2. Run `bundle install` to install dependencies.
3. Use `bin/console` to interact with the vending machine.
4. Run `rake` to execute tests.

## Ruby Version
Make sure you have Ruby 3.3.4 installed. You can use a version manager like `rbenv` or `RVM` to manage Ruby versions.