class PriceTicker {


  constructor(api_base_url, htmlPriceFragment) {
    this.api_base_url = api_base_url;
    this.api_exchange_rate_endpoint_btc = api_base_url + 'exchange-rates?currency=BTC'
    this.api_spot_price_btc = api_base_url + '/prices/BTC-USD/spot'
    this.htmlPriceFragment = htmlPriceFragment
  }

  updateHTML(price) {
    $(this.htmlPriceFragment).html(price)
  }

  fetchLatestPriceAndUpdate() {


    var self = this

    fetch(this.api_spot_price_btc).then(function(response) {
      var contentType = response.headers.get("content-type");
      if(contentType && contentType.includes("application/json")) {
        return response.json();
      }
      throw new TypeError("Oops, we haven't got JSON!");
    })
    .then(function(json) { 

      //var btcUsdPrice = json['data']['rates']['USD']  //exchange-rates endpoint
      var btcUsdPrice = json['data']['amount'] // prices endpoint
      
      self.updateHTML(btcUsdPrice)

    })
    .catch(function(error) { console.log(error) })


  }


}


function initializePriceTickerPolling(url, refreshInterval, htmlPriceFragment) {

      pt = new PriceTicker(url, htmlPriceFragment)
      let refreshIntervalMs = refreshInterval*1000

      function refreshPrice() {
        pt.fetchLatestPriceAndUpdate()
      }
      
      refreshPrice()
      setInterval(refreshPrice, refreshIntervalMs);

}