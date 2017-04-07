Gem::Specification.new do |s|
  s.name        = 'SEPAlibs'
  s.version     = '0.0.1'
  s.date        = '2017-04-07'
  s.summary     = "SEPA client libs"
  s.description = "Client-side libraries for SEPA"
  s.authors     = ["Fabio Viola"]
  s.email       = 'fabio.viola@unibo.it'
  s.files       = ["lib/Aggregator.rb", 
                   "lib/BasicHandler.rb",
                   "lib/Consumer.rb",
                   "lib/Errors.rb",
                   "lib/HTTPManager.rb",
                   "lib/KP.rb",
                   "lib/LowKP.rb",
                   "lib/Producer.rb",
                   "lib/SAPhandler.rb",
                   "lib/SepaKPIError.rb",
                   "LICENSE.txt"
  		  ]
  s.homepage    = 'http://wot.arces.unibo.it'
  s.license     = 'GPLv3'
end
