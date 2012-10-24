require 'pp'
require 'yajl/json_gem'
require 'stringio'
require 'cgi'

module Spree
  module Resources
    module Helpers
      STATUSES = {
        200 => '200 OK',
        201 => '201 Created',
        202 => '202 Accepted',
        204 => '204 No Content',
        301 => '301 Moved Permanently',
        302 => '302 Found',
        307 => '307 Temporary Redirect',
        304 => '304 Not Modified',
        401 => '401 Unauthorized',
        403 => '403 Forbidden',
        404 => '404 Not Found',
        409 => '409 Conflict',
        422 => '422 Unprocessable Entity',
        500 => '500 Server Error'
      }

      AUTHORS = {
        :technoweenie => '821395fe70906c8290df7f18ac4ac6cf',
        :pengwynn     => '7e19cd5486b5d6dc1ef90e671ba52ae0',
        :pezra        => 'f38112009dc16547051c8ac246cee443'
      }

      DefaultTimeFormat = "%B %-d, %Y".freeze

      def post_date(item)
        strftime item[:created_at]
      end

      def strftime(time, format = DefaultTimeFormat)
        attribute_to_time(time).strftime(format)
      end

      def gravatar_for(login)
        %(<img height="16" width="16" src="%s" />) % gravatar_url_for(login)
      end

      def gravatar_url_for(login)
        md5 = AUTHORS[login.to_sym]
        default = "https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"
        "https://secure.gravatar.com/avatar/%s?s=20&d=%s" %
          [md5, default]
      end

      def headers(status, head = {})
        css_class = (status == 201 || status == 204 || status == 404) ? 'headers no-response' : 'headers'
        lines = ["Status: #{STATUSES[status]}"]

        %(<pre class="#{css_class}"><code>#{lines * "\n"}</code></pre>\n)
      end

      def json(key)
        hash = case key
          when Hash
            h = {}
            key.each { |k, v| h[k.to_s] = v }
            h
          when Array
            key
          else Resources.const_get(key.to_s.upcase)
        end

        hash = yield hash if block_given?

        %(<pre class="highlight"><code class="language-javascript">) +
          JSON.pretty_generate(hash) + "</code></pre>"
      end

      def warning(message)
        %(<div class='warning'>) + message + %(</div>)
      end

      def admin_only
        warning("This action is only accessible by an admin user.") 
      end

      def text_html(response, status, head = {})
        hs = headers(status, head.merge('Content-Type' => 'text/html'))
        res = CGI.escapeHTML(response)
        hs + %(<pre class="highlight"><code>) + res + "</code></pre>"
      end
    end

    IMAGE =
      {"image"=>
         {"id"=>1,
          "position"=>1,
          "attachment_content_type"=>"image/jpg",
          "attachment_file_name"=>"ror_tote.jpeg",
          "type"=>"Spree::Image",
          "attachment_updated_at"=>nil,
          "attachment_width"=>360,
          "attachment_height"=>360,
          "alt"=>nil,
          "viewable_type"=>"Spree::Variant",
          "viewable_id"=>1}
      }

    OPTION_VALUE = 
      {"option_value"=>
        {
          "id"=>1,
          "name"=>"Small",
          "presentation"=>"S",
          "option_type_name"=>"tshirt-size",
          "option_type_id"=>1
        }
      }

    VARIANT =
      { "variant"=>
         {
           "id"=>1,
            "name"=>"Ruby on Rails Tote",
            "count_on_hand"=>10,
            "sku"=>"ROR-00011",
            "price"=>"15.99",
            "weight"=>nil,
            "height"=>nil,
            "width"=>nil,
            "depth"=>nil,
            "is_master"=>true,
            "cost_price"=>"13.0",
            "permalink"=>"ruby-on-rails-tote",
            "option_values"=> [OPTION_VALUE]
         }
      }

    PRODUCT_PROPERTY = 
      {"product_property"=>
        {
          "id"=>1,
          "product_id"=>1,
          "property_id"=>1,
          "value"=>"Tote",
          "property_name"=>"bag_type"
         }
       }

    PRODUCT = 
      {"product"=>
        {
          "id"=>1,
          "name"=>"Example product",
          "description"=> "Description",
          "price"=>"15.99",
          "available_on"=>"2012-10-17T03:43:57Z",
          "permalink"=>"ruby-on-rails-tote",
          "count_on_hand"=>10,
          "meta_description"=>nil,
          "meta_keywords"=>nil,
          "variants"=> [VARIANT],
          "images"=> [IMAGE],
          "option_types"=>[],
          "product_properties"=> [PRODUCT_PROPERTY]
        }
      }
    end

end

include Spree::Resources::Helpers
