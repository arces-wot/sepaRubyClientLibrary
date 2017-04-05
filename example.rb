#!/usr/bin/ruby

# requirements
load 'Producer.rb'
load 'Consumer.rb'

# create a producer
p = Producer.new("resources/chat.sap", nil, true)
p.produce('INSERT DATA { <http://ns#rubySub> <http://ns#rubyPred> "rubyObj" }')
p.produce('DELETE DATA { <http://ns#rubySub> <http://ns#rubyPred> "rubyObj" }')

# create a consumer
c = Consumer.new("resources/chat.sap", nil, true)
c.consume("SELECT ?s WHERE { ?s ?p ?o }")
