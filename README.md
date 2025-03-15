# SQLreport

This gem provides an easy way to convert SQL database queries to CSV. Below you can find the details of running this library.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Generating a Result object](#generating-a-result-object)
  - [Convert result data to CSV](#convert-result-data-to-csv)
  - [Get columns / headers](#get-column-headers)
  - [Get rows](#get-rows)
- [Compatibility](#compatibility)
- [Todo](#todo)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sqlreport'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqlreport

## Usage

This library will connect your primary database connection. You can enter a query and get a result.
With this result you can get the headers, columns and convert the results to a CSV

### Generating a Result object
To generate a new result call this following method:
```ruby
Sqlreport.query("SELECT * FROM test_table").result
```
Response
```ruby
  <Sqlreport::Result:0x000000011f4db730>
```

## Convert result data to CSV
To convert data to CSV just run the following command:
```ruby
result = Sqlreport.query("SELECT * FROM test_table").result
result.to_csv(include_headers: true, separator: ",", quote_char: '"')
```
Response
```ruby
  "id, name, other columns\t1,First name,other columns\t..."
```

## Get columns / headers
To rertieve the column names use the following commands:
```ruby
result = Sqlreport.query("SELECT * FROM test_table").result
result.columns
```
Response
```ruby
  ['id', 'name', 'other columns']
```

## Get rows
To rertieve the row data without the headers use the following commands:
```ruby
result = Sqlreport.query("SELECT * FROM test_table").result
result.rows
```
Response
```ruby
  [[1, "First name", "Other columns"], [2, "Second name", "Other columns"]]
```

This gem is tested with the following Ruby versions on Linux and Mac OS X:

- Ruby > 2.2.2

## Todo

- Batch jobs
- Add support for multiple export options (PDF, textfile, LaTex)
- Add safeguard validations
- Tie into Rails models
- Allow it to use different databases
- ..

## Contributing

1. Fork it ( https://github.com/gem-shards/sqlreport/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
