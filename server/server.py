import os, sys, graph, cherrypy
import simplejson as json

'''USAGE: python src/server.py <www-path> <port>'''

class Server(object):

  def __init__(self):
    self.graphs = {}

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def kb_exists(self, hashValue):
    return hashValue in self.graphs

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def create_kb(self, hashValue, assertions, axesList, nodeType):
    graph_instance = graph.create_graph(json.loads(assertions), json.loads(axesList), nodeType)
    self.graphs[hashValue] = graph_instance
    return {"hashValue": hashValue}

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_nodes(self, hashValue):
    return self.graphs[hashValue].get_nodes();

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_edges(self, hashValue, node, otherNodes):
    return self.graphs[hashValue].get_edges(json.loads(node), json.loads(otherNodes))

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_related_nodes(self, hashValue, nodes, numNodes):
    return self.graphs[hashValue].get_related_nodes(json.loads(nodes), int(numNodes))

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_truth(self, hashValue, node):
    node = json.loads(node)
    return self.graphs[hashValue].get_truth(node["concept1"], node["concept2"], node["relation"])

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_concepts(self, hashValue):
    return self.graphs[hashValue].get_concepts()

  @cherrypy.expose
  @cherrypy.tools.json_out()
  def get_relations(self, hashValue):
    return self.graphs[hashValue].get_relations()

if __name__ == '__main__':

  # parse command line arguments
  www_path, port_str = sys.argv[1:]
  port = int(port_str)

  # configure cherrypy to properly accept requests
  cherrypy.config.update({'server.socket_host': '0.0.0.0',
                          'server.socket_port': port})
  Server._cp_config = {
    'tools.staticdir.on' : True,
    'tools.staticdir.dir' : os.path.abspath(www_path),
    'tools.staticdir.index' : 'index.html',
  }

  # start server
  cherrypy.quickstart(Server())
