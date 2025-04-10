# SQLreport

This gem provides an easy way to convert SQL database queries to CSV. Below you can find the details of running this library.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Generating a Result object](#generating-a-result-object)
  - [Convert result data to CSV](#convert-result-data-to-csv)
  - [Write result to CSV file](#write-result-to-csv-file)
  - [Get columns / headers](#get-column-headers)
  - [Get rows](#get-rows)
- [Batch Processing](#batch-processing)
  - [Creating a Batch Manager](#creating-a-batch-manager)
  - [Processing Batches](#processing-batches)
  - [Streaming to CSV](#streaming-to-csv)
  - [Tracking Progress](#tracking-progress)
- [ActiveRecord Integration](#activerecord-integration)
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

## Write result to CSV file
To write the CSV data to a file just run the following command:
```ruby
result = Sqlreport.query("SELECT * FROM test_table").result
result.write_csv("test_table.csv")
```
Response
```ruby
  true
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

## Batch Processing

For handling large datasets, SQLreport provides batch processing capabilities that allow you to process data in chunks to avoid memory issues.

### Creating a Batch Manager

```ruby
batch_manager = Sqlreport.batch_query("SELECT * FROM large_table", batch_size: 1000)
```

### Processing Batches

You can process one batch at a time:

```ruby
# Get the next batch
batch = batch_manager.next_batch
# Process the batch
batch.rows.each do |row|
  # Process each row
end
```

Or process all batches at once with a block:

```ruby
batch_manager.process_all do |batch|
  # Process each batch
  puts "Processing batch with #{batch.rows.count} rows"
end
```

### Streaming to CSV

For very large datasets, you can stream directly to a CSV file without loading all data into memory:

```ruby
batch_manager.stream_to_csv("large_table.csv")
```

### Tracking Progress

You can track the progress of batch processing:

```ruby
batch_manager.count_total_rows # Get total row count for progress calculation
batch_manager.next_batch
puts "Processed #{batch_manager.processed_rows} of #{batch_manager.total_rows} rows"
puts "Progress: #{batch_manager.progress_percentage}%"
```

## ActiveRecord Integration

SQLreport can be used directly with ActiveRecord models and relations, allowing for a more fluent interface:

```ruby
# Generate a report from an ActiveRecord relation
User.where(active: true).sqlreport.result.write_csv("active_users.csv")

# Or with more options
Post.where(published: true)
    .order(created_at: :desc)
    .limit(100)
    .sqlreport
    .result
    .to_csv(include_headers: true, separator: ",")

# Use batch processing with ActiveRecord
User.where(created_at: 1.month.ago..Time.current)
    .sqlreport_batch(batch_size: 500)
    .stream_to_csv("new_users.csv")
```

This integration makes it easy to generate reports directly from your models without having to write raw SQL.

## Todo

- ~~Add simple safeguard validations~~
- ~~Allow it to use different databases~~
- ~~Batch jobs (for bigger tables)~~
- ~~Tie into Rails models~~
- Add support for multiple export options (PDF, textfile, LaTex)
- ..

## Contributing

1. Fork it ( https://github.com/gem-shards/sqlreport/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
