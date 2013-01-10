module DSpaceCSV
  #TODO: remove these!
  class Bitstream; end
  class Bundle; end
  class Item; end
  class Collection; end
  class Community; end
  class Site; end

  # lets you look up type names from the type IDs
  RESOURCE_TYPE = {
    0 => { rest_path: "bitstream/" },
    1 => { rest_path: nil },
    2 => { rest_path: "items/" },
    3 => { rest_path: "collections/" },
    4 => { rest_path: "communities/" },
    5 => { rest_path: nil },
    6 => { rest_path: "groups" },
    7 => { rest_path: "users" }
  }

end
