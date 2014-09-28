#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

# Sample Article: "1. [DOI] [PDF] ANDRADE, B.T., MENDES, C.M., SANTOS JUNIOR, J.O., BELLON, O.R.P. and SILVA, L.: 3D preserving XVIII century barroque masterpiece: challenges and results on the digital preservation of Aleijadinho's sculpture of the Prophet Joel. Journal of Cultural Heritage (2011)."

def to_ieee(authors)
  authors.collect { |a|
    names = a.split
    r = names.pop.gsub(" ", "") + ", "
    names.each { |n| r << n[0] << "." }
    r
  }
end

class Article
  attr_accessor :title, :authors, :booktitle, :link, :year, :date

  def to_html
    s = ""
    s << "<a href=\"#{@link}\">[DOI]</a> " if link
    s << to_ieee(@authors).join(", ").upcase << ": "
    s << "<b>#{@title}</b> "
    s << "<i>#{@booktitle}</i> "
    s << "(#{@year})."
  end
end

def parseDblpXml(xmlFile)
  articles = Array.new

  doc = Nokogiri::XML(File.open(xmlFile)) { |config|
    config.strict.nonet
  }

  doc.xpath("//r").each { |xmlArticle|
    a = Article.new

    title = xmlArticle.search("title").first
    next unless title
    a.title = title.content if title

    year = xmlArticle.search("year").first
    a.year = year.content if year

    link = xmlArticle.search("ee").first
    a.link = link.content if link

    booktitle = xmlArticle.search("booktitle").first
    booktitle = xmlArticle.search("journal").first unless booktitle
    a.booktitle = booktitle.content if booktitle

    a.authors = Array.new
    xmlArticle.search("author").each { |author|
      a.authors << author.content
    }
    xmlArticle.search("editor").each { |author|
      a.authors << author.content
    }

    articles << a
  }

  articles
end

articles = parseDblpXml("Bellon:Olga_Regina_Pereira.xml")

puts "<h1 style=\"text-align: justify;\">Last Publications</h1>"
puts "<p style=\"text-align: justify;\">"
articles.each_index { |aid| puts "#{aid + 1}. #{articles[aid].to_html}" }
puts "</p>"


