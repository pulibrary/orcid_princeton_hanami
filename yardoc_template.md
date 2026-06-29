# Improved YARD CHEATSHEET http://yardoc.org

Based on https://gist.github.com/chetan/1827484

* [Official Getting Started Guide](http://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md)
* [Official Tags documentation](http://www.rubydoc.info/gems/yard/file/docs/Tags.md#Tag_List)
* [Type naming examples](https://yardoc.org/types)

Templates to remind you of the options and formatting for the different types of objects you might
want to document using YARD.

## Linking Objects {...}

To link another "object" (class, method, module, etc.), use the format:

    {ObjectName#method OPTIONAL_TITLE}
    {Class::CONSTANT My constant's title}
    {#method_inside_current_namespace}

## Methods

    # An alias to {Parser::SourceParser}'s parsing method
    # 
    # @author Donovan Bray
    #
    # @see http://example.com Description of URL
    # @see SomeOtherClass#method
    #
    # @deprecated Use {#my_new_method} instead of this method because
    #   it uses a library that is no longer supported in Ruby 1.9. 
    #   The new method accepts the same parameters.
    #
    # @abstract
    # @private

### Method parameters

    # @param opts [Hash] the options to create a message with.
    # @option opts [String] :subject The subject
    # @option opts [String] :from ('nobody') From address
    # @option opts [String] :to Recipient email
    # @option opts [String] :body ('') The email's body 
    def send_email(opts = {}) end

    # @param (see User#initialize)
    # @param opts [OptionParser] the option parser object
    # @param args [Array<String>] the arguments passed from input. This
    #   array will be modified.
    # @param list [Array<String, Symbol>] the list of strings and symbols.
    # @param hash [Hash<Symbol, String>] a hash with symbol keys and string values
    #
    # The options parsed out of the commandline.
    # Default options are:
    #   :format => :dot
    
### Examples

    # @example Reverse a string
    #   "mystring".reverse #=> "gnirtsym"
    #
    # @example Parse a glob of files
    #   YARD.parse('lib/**/*.rb')
## Modules

    # Namespace for classes and modules that handle serving documentation over HTTP
    # @since 0.6.0

## Classes

    # Abstract base class for CLI utilities. Provides some helper methods for
    # the option parser
    # 
    # @author Full Name
    # @abstract
    # @since 0.6.0
    # @deprecated Describe the reason or provide alt. references here
    #
    # # Attributes can be documented directly like this
    # attr_reader :hello
    #
    # If you generate attributes via meta programming, use
    # @!attribute [r | w | rw] attribute_name

See https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attribute for more information on documenting attributes.

### Exceptions

    # @raise [ExceptionClass] description

### Return values

    # @return [optional, types, ...] description
    # @return [true] always returns true
    # @return [void]
    # @return [String, nil] the contents of our object or nil
    #   if the object has not been filled with data.
    #
    # We don't care about the "type" here:
    # @return the object
    #
    # @return [String, #read] a string or object that responds to #read
    # @return description here with no types

## Anywhere

    # @todo Add support for Jabberwocky service
    #   There is an open source Jabberwocky library available 
    #   at http://somesite.com that can be integrated easily
    #   into the project.

## Blocks

    # for block {|a, b, c| ... }
    # @yield [a, b, c] Description of block
    #
    # @yieldparam [optional, types, ...] argname description
    # @yieldreturn [optional, types, ...] description
