module DSpaceCSV
  # Type of bitstream objects 
  BITSTREAM = 0

  # Type of bundle objects 
  BUNDLE = 1

  # Type of item objects 
  ITEM = 2

  # Type of collection objects 
  COLLECTION = 3

  # Type of community objects 
  COMMUNITY = 4

  # DSpace site type 
  SITE = 5

  # Type of eperson groups 
  GROUP = 6

  # Type of individual eperson objects 
  EPERSON = 7

  # lets you look up type names from the type IDs
  RESOURCE_TYPE = [ "BITSTREAM", "BUNDLE", "ITEM",
          "COLLECTION", "COMMUNITY", "SITE", "GROUP", "EPERSON" ]
end
