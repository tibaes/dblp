#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

class Article
  attr_accessor :title, :authors, :link, :year, :date

  def to_html
    s = "<b>#{@title}</b>"
    s << "<i>" << @authors.join(", ") << "</i>"
    s << "(#{@year})"
  end
end

def parseDblpXml(xmlFile)
  articles = Array.new
  
  doc = Nokogiri::XML(File.open(xmlFile)) { |config|
    config.strict.nonet
  }
  
  doc.xpath("//r").each { |article|
    a = Article.new
    
    title = article.search("title").first
    next unless title
    a.title = title.content if title
    
    year = article.search("year").first
    a.year = year.content if year
    
    link = article.search("ee").first
    a.link = link.content if link
    
    a.authors = Array.new
    article.search("author").each { |author|
      a.authors << author.content
    }
    article.search("editor").each { |author|
      a.authors << author.content
    }
    
    articles << a
  }
  
  articles
end

articles = parseDblpXml("Bellon:Olga_Regina_Pereira.xml")

puts articles.first.to_html







