# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(title: movie[:title], rating: movie[:rating], release_date: movie[:release_date]) # kp fixed this 
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  Movie.count.should be n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  begin
    # Check if e1 and e2 are dates.
    DateTime.parse e1
    DateTime.parse e2
  
    within(:xpath, %(//table[@id="movies"]/tbody)) do
      release_dates = page.all(:xpath, "//td[3]").to_a.map do 
        |el| DateTime.parse(el.text)
      end.compact
      
      expect(release_dates.index(e1) < release_dates.index(e2)).to be true
    end
  rescue ArgumentError
    expect(page.body.index(e1) < page.body.index(e2)).to be true
  end
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split /,\s*/ do |rating| # kp fixed this
    step %(I #{uncheck}check "ratings[#{rating}]")
  end
end
    

Then /I should see all the movies/ do
  # Make sure that all the movies in the app are visible in the table
  expect(page).to have_xpath(".//tr[not(ancestor::thead)]", :count => Movie.count)
end

# Make it easier to express ensuring several movies are or are not visible at once

Then /I should (not )?see the following movies: (.*)/ do |not_, movies|
  movies.split /,\s*/ do |movie|
    step %(I should #{not_}see "#{movie}")
  end
end




Then (/^I should not see movies rated: G, PG\-(\d+)$/) do |rating_list|
  rating_list.split(", ").each do |text|
    (page.body=~/\Atext\z/) == nil 
  end
end