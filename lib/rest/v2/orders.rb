module Bitfinex
  module RESTv2Orders
    # Get active orders
    #
    # example:
    # client.orders
    def orders
      authenticated_post("auth/r/orders").body
    end

    # Get Trades generated by an Order
    #
    # @param order_id [int32] Id of the order
    # @param symbol [string] symbol used for the order
    #
    # @return [Array]
    #
    # @example:
    #   client.order_trades 10010, "tBTCUSD"
    #
    def order_trades(order_id, symbol="tBTCUSD")
      authenticated_post("auth/r/order/#{symbol}:#{order_id}/trades").body
    end

    ###
    # Submit a new order
    #
    # @param [Hash|Order] order
    #
    # @return [Array] Raw notification
    ###
    def submit_order(order)
      if order.instance_of?(Models::Order)
        packet = order.to_new_order_packet
      elsif order.kind_of?(Hash)
        packet = Models::Order.new(order).to_new_order_packet
      else
        raise Exception, 'tried to submit order of unkown type'
      end

      if !@aff_code.nil?
        unless packet[:meta]
          packet[:meta] = {}
        end

        packet[:meta][:aff_code] = @aff_code
      end

      authenticated_post("auth/w/order/submit", params: packet).body
    end

    ###
    # Update an order with a changeset by ID
    #
    # @param [Hash] changes - must contain ID
    #
    # @return [Array] Raw notification
    ###
    def update_order (changes)
      authenticated_post("auth/w/order/update", params: changes).body
    end

    ###
    # Cancel an order by ID
    #
    # @param [Hash|Array|Order|number] order - must contain or be ID
    #
    # @return [Array] Raw notification
    ###
    def cancel_order (order)
      if order.is_a?(Numeric)
        id = order
      elsif order.is_a?(Array)
        id = order[0]
      elsif order.instance_of?(Models::Order)
        id = order.id
      elsif order.kind_of?(Hash)
        id = order[:id] || order['id']
      else
        raise Exception, 'tried to cancel order with invalid ID'
      end
      authenticated_post("auth/w/order/cancel", params: { :id => id }).body
    end

    # TODO - requires websocket implementation as well
    def cancel_multi ()
      raise Exception, 'not implemented'
    end

    # TODO - requires websocket implementation as well
    def order_multi ()
      raise Exception, 'not implemented'
    end
  end
end
