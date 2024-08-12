module Magento
  class Project44Apis
    include HTTParty

    attr_accessor :bearer_token, :post_url

    def initialize
      @post_url = "https://na12.api.project44.com/api/v4/ltl/trackedshipments"
    end

    def track_shipment(order,shipping_detail)
      @state = STATE_ABBR_TO_NAME(order.shipping_address.address2)
      @store_address = StoreAddress.find_by(store: order.store)
      @shipping_detail = ShippingDetail.find(shipping_detail.id)
      @shipped_date = @shipping_detail.shipped_date
      @start_days = 0
      @end_days = 0
      if StateDay.find_by(state: @state).present?
        @start_days = StateDay.find_by(state: @state).start_days.to_i
        @end_days = StateDay.find_by(state: @state).end_days.to_i
      end
      if order.store == 'us'
        @country = 'US'
      else order.store == 'canada'
        @country = 'CA'
      end
      if @shipping_detail.carrier.tracking_method == "PRO"
        @type = "PRO"
      else
        @type = "BILL_OF_LADING"
      end
      
      if order.shipping_line.title.present? && (order.shipping_line.title == 'White Glove Service')
        response = HTTParty.post(@post_url,
                    :body => 
                      { 
                        "capacityProviderAccountGroup": {
                          "code": "Default",
                          "accounts": [
                            { "code": "#{@shipping_detail.carrier.carrierID}" }
                          ]
                        },
                        "shipmentIdentifiers": [
                          {
                            "type": @type,
                            "value": "#{@shipping_detail.tracking_number}",
                            "primaryForType": true,
                            "source": "CUSTOMER"
                          }
                        ],
                        "shipmentStops": [
                          {
                            "stopType": "ORIGIN",
                            "location": {
                              "address": {
                                "postalCode": "#{@store_address.zip}",
                                "addressLines": [
                                  "#{@store_address.address}"
                                ],
                                "city": "#{@store_address.city}",
                                "state": "#{STATE_ABBR_TO_NAME(@store_address.state)}",
                                "country": "#{@country}"
                              },
                              "contact": {
                                "companyName": "Eternity Modern",
                                "contactName": "Skylab Logistics",
                                "phoneNumber": "9496090351",
                                "phoneNumberCountryCode": "+1",
                                "email": "info@eternitymodern.com"
                              }
                            },
                            "appointmentWindow": {
                              "startDateTime": "#{@shipping_detail.shipped_date.to_date.strftime('%Y-%m-%d') + 'T08:30:00'}",
                              "endDateTime": "#{@shipping_detail.shipped_date.to_date.strftime('%Y-%m-%d') + 'T16:00:00'}"
                            }
                          },
                          {
                            "stopType": "DESTINATION",
                            "location": {
                              "address": {
                                "postalCode": "#{@shipping_detail.white_glove_address.zip}",
                                "addressLines": [
                                  "#{@shipping_detail.white_glove_address.address1.tr('[]','').tr('" "', ' ').titleize}"
                                ],
                                "city": "#{@shipping_detail.white_glove_address.city}",
                                "state": "#{STATE_ABBR_TO_NAME(@shipping_detail.white_glove_address.address2)}",
                                "country": "#{@shipping_detail.white_glove_address.country}"
                              },
                              "contact": {
                                "companyName": "Eternity Modern",
                                "contactName": "#{order.customer.full_name}",
                                "phoneNumber": "#{order.customer.phone}",
                                "phoneNumberCountryCode": "+1",
                                "email": "#{order.customer.email}"
                              }
                            },
                            "appointmentWindow": {
                              "startDateTime": "#{(@shipping_detail.shipped_date + @start_days.day).to_date.strftime('%Y-%m-%d') + 'T09:00:00'}",
                              "endDateTime": "#{(@shipping_detail.shipped_date + @end_days.day).to_date.strftime('%Y-%m-%d') + 'T17:00:00'}"
                            } 
                          }
                        ] }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Basic aW50ZWdyYXRpb251c2VyMkBub3J0aGJhbnEuY29tOk1YcSU1KmxJeng="
                    }, :verify => false)
                        
      else
        response = HTTParty.post(@post_url,
        :body => 
          { 
            "capacityProviderAccountGroup": {
              "code": "Default",
              "accounts": [
                { "code": "#{@shipping_detail.carrier.carrierID}" }
              ]
            },
            "shipmentIdentifiers": [
              {
                "type": @type,
                "value": "#{@shipping_detail.tracking_number}",
                "primaryForType": true,
                "source": "CUSTOMER"
              }
            ],
            "shipmentStops": [
              {
                "stopType": "ORIGIN",
                "location": {
                  "address": {
                    "postalCode": "#{@store_address.zip}",
                    "addressLines": [
                      "#{@store_address.address}"
                    ],
                    "city": "#{@store_address.city}",
                    "state": "#{STATE_ABBR_TO_NAME(@store_address.state)}",
                    "country": "#{@country}"
                  },
                  "contact": {
                    "companyName": "Eternity Modern",
                    "contactName": "Skylab Logistics",
                    "phoneNumber": "9496090351",
                    "phoneNumberCountryCode": "+1",
                    "email": "info@eternitymodern.com"
                  }
                },
                "appointmentWindow": {
                  "startDateTime": "#{@shipping_detail.shipped_date.to_date.strftime('%Y-%m-%d') + 'T08:30:00'}",
                  "endDateTime": "#{@shipping_detail.shipped_date.to_date.strftime('%Y-%m-%d') + 'T16:00:00'}"
                }
              },
              {
                "stopType": "DESTINATION",
                "location": {
                  "address": {
                    "postalCode": "#{order.shipping_address.zip}",
                    "addressLines": [
                      "#{order.shipping_address.address1.tr('[]','').tr('" "', ' ').titleize}"
                    ],
                    "city": "#{order.shipping_address.city}",
                    "state": "#{@state}",
                    "country": "#{order.shipping_address.country}"
                  },
                  "contact": {
                    "companyName": "Eternity Modern",
                    "contactName": "#{order.customer.full_name}",
                    "phoneNumber": "#{order.customer.phone}",
                    "phoneNumberCountryCode": "+1",
                    "email": "#{order.customer.email}"
                  }
                },
                "appointmentWindow": {
                  "startDateTime": "#{(@shipping_detail.shipped_date + @start_days.day).to_date.strftime('%Y-%m-%d') + 'T09:00:00'}",
                  "endDateTime": "#{(@shipping_detail.shipped_date + @end_days.day).to_date.strftime('%Y-%m-%d') + 'T17:00:00'}"
                } 
              }
            ] }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Basic aW50ZWdyYXRpb251c2VyMkBub3J0aGJhbnEuY29tOk1YcSU1KmxJeng="
        }, :verify => false)

      end
      
      puts response

      if (response.keys.include? 'shipment') && response['shipment']['id'].present?
        @map_url = get_map_url(response['shipment']['id'])
        @shipping_detail.update(map_id: response['shipment']['id'])
        @shipping_detail.update(tracking_url_for_ship: @map_url)
        @shipping_detail = ShippingDetail.find(@shipping_detail.id)
        # Magento::UpdateOrder.new(order.store).create_shipment(order,@shipping_detail) if @shipping_detail.tracking_url_for_ship.present?
        @shipping_detail.update(error_notes: nil)
      elsif response.present?
        @shipping_detail.update(error_notes: 'Failure in creating tracking_url')
      end
    end

    def get_map_url(id)
      response = HTTParty.get("https://na12.api.project44.com/api/v4/ltl/trackedshipments/#{id}/statuses?includeStatusHistory=TRUE&includeMapUrl=TRUE", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Basic aW50ZWdyYXRpb251c2VyMkBub3J0aGJhbnEuY29tOk1YcSU1KmxJeng="
      }, :verify => false)
      puts response
      response['mapUrl']
    end

    def STATE_ABBR_TO_NAME(city)
      a = {
        'AL' => 'Alabama',
        'AK' => 'Alaska',
        'AS' => 'America Samoa',
        'AZ' => 'Arizona',
        'AR' => 'Arkansas',
        'CA' => 'California',
        'CO' => 'Colorado',
        'CT' => 'Connecticut',
        'DE' => 'Delaware',
        'DC' => 'District of Columbia',
        'FM' => 'Federated States Of Micronesia',
        'FL' => 'Florida',
        'GA' => 'Georgia',
        'GU' => 'Guam',
        'HI' => 'Hawaii',
        'ID' => 'Idaho',
        'IL' => 'Illinois',
        'IN' => 'Indiana',
        'IA' => 'Iowa',
        'KS' => 'Kansas',
        'KY' => 'Kentucky',
        'LA' => 'Louisiana',
        'ME' => 'Maine',
        'MH' => 'Marshall Islands',
        'MD' => 'Maryland',
        'MA' => 'Massachusetts',
        'MI' => 'Michigan',
        'MN' => 'Minnesota',
        'MS' => 'Mississippi',
        'MO' => 'Missouri',
        'MT' => 'Montana',
        'NE' => 'Nebraska',
        'NV' => 'Nevada',
        'NH' => 'New Hampshire',
        'NJ' => 'New Jersey',
        'NM' => 'New Mexico',
        'NY' => 'New York',
        'NC' => 'North Carolina',
        'ND' => 'North Dakota',
        'OH' => 'Ohio',
        'OK' => 'Oklahoma',
        'OR' => 'Oregon',
        'PW' => 'Palau',
        'PA' => 'Pennsylvania',
        'PR' => 'Puerto Rico',
        'RI' => 'Rhode Island',
        'SC' => 'South Carolina',
        'SD' => 'South Dakota',
        'TN' => 'Tennessee',
        'TX' => 'Texas',
        'UT' => 'Utah',
        'VT' => 'Vermont',
        'VI' => 'Virgin Island',
        'VA' => 'Virginia',
        'WA' => 'Washington',
        'WV' => 'West Virginia',
        'WI' => 'Wisconsin',
        'WY' => 'Wyoming'
      }

      if a.values.include? city
        a.key(city)
      end
    end
  end
end