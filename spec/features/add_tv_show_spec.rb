require 'spec_helper'

SPONGEBOB_SYNOPSIS = ''
200.times { SPONGEBOB_SYNOPSIS << 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?' }

feature 'user adds a new TV show' do
  # As a TV fanatic
  # I want to add one of my favorite shows
  # So that I can encourage others to binge watch it
  #
  # Acceptance Criteria:
  # * I must provide the title, network, and starting year.
  # * I can optionally provide the final year, genre, and synopsis.
  # * The synopsis can be no longer than 5000 characters.
  # * The starting year and ending year (if provided) must be
  #   greater than 1900.
  # * The genre must be one of the following: Action, Mystery,
  #   Drama, Comedy, Fantasy
  # * If any of the above validations fail, the form should be
  #   re-displayed with the failing validation message.

  scenario 'successfully add a new show' do
    visit '/television_shows/new'

    fill_in('television_show[title]', with: 'Arrested Development')
    fill_in('television_show[network]', with: 'Fox')
    fill_in('television_show[starting_year]', with: '2003')
    fill_in('television_show[ending_year]', with: '2005')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: "Michael Bluth takes over the family construction business after his father's arrest.")
    click_button('Add TV Show')
    click_link('Arrested Development (Fox)')

    expect(page).to have_content('Arrested Development')
    expect(page).to have_content('Fox')
    expect(page).to have_content('2003')
    expect(page).to have_content('2005')
    expect(page).to have_content('Comedy')
    expect(page).to have_content("Michael Bluth takes over the family construction business after his father's arrest.")
  end

  scenario 'fail to add a show with invalid information' do
    # no title
    visit 'television_shows/new'

    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content("Title can't be blank")

    # no network
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content("Network can't be blank")

    # no starting year
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content("Starting year can't be blank")

    # starting year not a number

    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '199A')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content('Starting year is not a number')

    # synopsis too long
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: SPONGEBOB_SYNOPSIS)
    click_button('Add TV Show')

    expect(page).to have_content('Synopsis is too long (maximum is 5000 characters)')

    # starting year before 1900
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1799')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content('Starting year must be greater than 1900')

    # ending year before 1900
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    fill_in('television_show[ending_year]', with: '1799')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content('Ending year must be greater than 1900')

    # genre not included in list
    visit 'television_shows/new'

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Choose', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Add TV Show')

    expect(page).to have_content('Genre is not included in the list')
  end
end
