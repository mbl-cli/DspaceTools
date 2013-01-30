class DSpaceCSV
  #TODO: remove these!
  class Bitstream; end
  class Bundle; end
  class Site; end

  # lets you look up type names from the type IDs
  RESOURCE_TYPE = {
    0 => { rest_path: "bitstreams/", klass: Bitstream },
    1 => { rest_path: nil },
    2 => { rest_path: "items/", klass: Item },
    3 => { rest_path: "collections/", klass: Collection },
    4 => { rest_path: "communities/", klass: Community},
    5 => { rest_path: nil },
    6 => { rest_path: "groups/", klass: Group },
    7 => { rest_path: "users/", klass: Eperson }
  }

  RESOURCE_TYPE_IDS = RESOURCE_TYPE.select{|key, value| value[:rest_path]}.inject({}) {|res, rt| res[rt[1][:klass]] = rt[0]; res} 
  RESOURCE_TYPE_PATHS= RESOURCE_TYPE.select{|key, value| value[:rest_path]}.inject({}) {|res, rt| res[rt[1][:rest_path][0..-2]] = rt[0]; res} 

  ACTION = [ "READ", "WRITE",
            "OBSOLETE (DELETE)", "ADD", "REMOVE", "WORKFLOW_STEP_1",
            "WORKFLOW_STEP_2", "WORKFLOW_STEP_3", "WORKFLOW_ABORT",
            "DEFAULT_BITSTREAM_READ", "DEFAULT_ITEM_READ", "ADMIN" ]

  ACTION_TYPE = ACTION.inject({}) { |res, type| res[type] = res.size; res }

  ACCESS_ACTIONS = [ ACTION_TYPE["READ"], ACTION_TYPE["ADMIN"] ]

end
