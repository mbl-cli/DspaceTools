FG.define do

  factory :community do
    community_id nil
    sequence(:name) {|n| "community%s" % n}
    short_description 'short desc'
    introductory_text 'intro_text'
    logo_bitstream_id 1
    copyright_text 'Copyright'
    side_bar_text 'sidebar'
    admin 1
  end

  factory :collection do
    collection_id nil
    sequence(:name) {|n| "collection%s" % n}
    short_description 'short_desc'
    introductory_text 'intro_text'
    logo_bitstream_id 1
    template_item_id 1
    provenance_description 'provenance'
    license 'MIT'
    copyright_text 'Copyright'
    side_bar_text 'sidebar'
    workflow_step_1 'wf1'
    workflow_step_2 'wf2'
    submitter 1
    admin 1
  end

  factory :item do
    item_id nil
    submitter_id 1
    in_archive 't'
    withdrawn 'f'
    last_modified Time.now
    owning_collection 31
  end

  factory :bitstream do
    bitstream_id nil
    bitstream_format_id 1
    sequence(:name) {|n| "bitstream%s" % n}
    size_bytes 1
    checksum 123
    checksum_algorithm 'MD5'
    description 'desc'
    user_format_description 'user format desc'
    source 'source'
    internal_id 123
    deleted 'f'
    store_number 1
    sequence_id 1
  end

  factory :bitstreamformat do
    bitstream_format_id nil
    mimetype 'application/octet-stream'
    short_description 'unknown'
    description 'unknown mimetype'
    support_level 1
    internal 'f'
  end

  factory :resourcepolicy do
    sequence(:policy_id)
    resource_type_id 2
    resource_id nil
    action_id 0
    eperson_id nil
    epersongroup_id nil
    start_date nil
    end_date nil
  end
end
