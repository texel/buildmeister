class Hash
  def self.from_xml(xml)
    xml_parsed = ActiveSupport::XmlMini.parse(xml)
    if xml_parsed["tickets"]
      xml_parsed["tickets"].delete "current_page"
      xml_parsed["tickets"].delete "total_pages"
    end
    typecast_xml_value(unrename_keys(xml_parsed))
  end
end
