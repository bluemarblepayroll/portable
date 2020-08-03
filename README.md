# Portable

[![Gem Version](https://badge.fury.io/rb/portable.svg)](https://badge.fury.io/rb/portable) [![Build Status](https://travis-ci.org/bluemarblepayroll/portable.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/portable) [![Maintainability](https://api.codeclimate.com/v1/badges/4b47ce94b0c9d889e648/maintainability)](https://codeclimate.com/github/bluemarblepayroll/portable/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/4b47ce94b0c9d889e648/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/portable/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This library provides a configuration layer that allows you to express transformations, using [Realize](https://github.com/bluemarblepayroll/realize), and will write the transformed data down to disk.  Essentially it is meant to be the transformation and load steps within a larger ETL system. We currently use this in production paired up with [Dbee](https://github.com/bluemarblepayroll/dbee) to go from configurable data model + query to file.

Current limitations:

1. Only supports CSV with limited options
2. Only supports writing to local file system.

Future extension considerations:

1. Support Excel and richer formatting, sheets, etc.
2. Expand CSV options: delimiter, forcing quotes, etc.
3. Support PDF

## Installation

To install through Rubygems:

````
gem install install portable
````

You can also add this to your Gemfile:

````
bundle add portable
````

## Examples

### Getting Started with Exports

Consider the following data set as an array of hashes:

````ruby
patients = [
  { first: 'Marky', last: 'Mark', dob: '2000-04-05' },
  { first: 'Frank', last: 'Rizzo', dob: '1930-09-22' }
]
````

We could configure an export like so:

````ruby
export = {
  columns: [
    { header: :first },
    { header: :last },
    { header: :dob }
  ]
}
````

And execute the export against the example dataset in order to generate a CSV file:

````ruby
writer   = Portable::Writer.new(export)
filename = File.join('tmp', 'patients.csv')

writer.open(filename) do |writer|
  patients.each do |patient|
    writer.write(object: patient)
  end
end
````

We should now have a CSV file at tmp/patients.csv that looks like this:

first | last | dob
----- | ---- | -----
Marky | Mark | 2000-04-05
Frank | Rizzo | 1930-09-22

### Realize Transformation Pipelines

This library uses Realize under the hood, so you have the option of configuring any transformation pipeline for each column.  Reviewing [Realize's list of transformers](https://github.com/bluemarblepayroll/realize#transformer-gallery) is recommended to see what is available.

Let's expand our example above with different headers and date formatting:

````ruby
export = {
  columns: [
    {
      header: 'First Name',
      transformers: [
        { type: 'r/value/resolve', key: :first }
      ]
    },
    {
      header: 'Last Name',
      transformers: [
        { type: 'r/value/resolve', key: :last }
      ]
    },
    {
      header: 'Date of Birth',
      transformers: [
        { type: 'r/value/resolve', key: :dob },
        { type: 'r/format/date', output_format: '%m/%d/%Y' },
      ]
    }
  ]
}
````

Executing it the same way would now yield a different CSV file:

First Name | Last Name | Date of Birth
---------- | --------- | -------------
Marky      | Mark      | 04/05/2000
Frank      | Rizzo     | 09/22/1930

Realize is also [pluggable](https://github.com/bluemarblepayroll/realize#plugging-in-transformers), so you are able to create your own and plug them directly into Realize.

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check portable.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/portable.git)
4. Navigate to the root folder (cd portable)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/portable/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/portable/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
