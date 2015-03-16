require 'spec_helper'

SPONGEBOB_SYNOPSIS = ''
200.times { SPONGEBOB_SYNOPSIS << 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?' }

feature 'user views list of TV shows' do
  # As a TV fanatic
  # I want to view a list of TV shows
  # So I can find new shows to watch
  #
  # Acceptance Criteria:
  # * I can see the names and networks of all TV shows

  scenario 'view list of TV shows' do
    # First create some sample TV shows
    game_of_thrones = TelevisionShow.create!(title: 'Game of Thrones', network: 'HBO',
                                             starting_year: 2011, genre: 'Fantasy')

    married_with_children = TelevisionShow.create!(title: 'Married... with Children', network: 'Fox',
                                                   starting_year: 1987, ending_year: 1997,
                                                   genre: 'Comedy')

    # The user visits the index page
    visit '/television_shows'

    # And should see both TV shows listed (just the title and network)
    expect(page).to have_content('Game of Thrones (HBO)')
    expect(page).to have_content('Married... with Children (Fox)')
  end

  # As a TV fanatic
  # I want to view the details for a TV show
  # So I can find learn more about it

  # Acceptance Criteria:
  # * I can see the title, network, start and end year, genre, and synopsis
  #   for a show.
  # * If the end year is not provided it should indicate that the show is still
  #   running.

  scenario 'view details for a TV show' do
    visit '/television_shows'
    click_link('Married... with Children (Fox)')

    expect(page).to have_content('Married... with Children')
    expect(page).to have_content('Fox')
    expect(page).to have_content('1987')
    expect(page).to have_content('1997')
    expect(page).to have_content('Comedy')
  end

  scenario 'view details for a TV show with missing information' do
    visit '/television_shows'
    click_link('Game of Thrones (HBO)')

    expect(page).to have_content('Game of Thrones')
    expect(page).to have_content('HBO')
    expect(page).to have_content('2011')
    expect(page).to have_content('Present')
    expect(page).to have_content('Fantasy')
  end

  # As a TV fanatic
  # I want to edit an existing show
  # So that I can correct any foolish mistakes

  # Acceptance Criteria:
  # * Editing a show provides a pre-populated form for each field.
  # * Submitting the edit form will update a show if all validations pass.
  # * The user is redirected to the details page for that show if successfully
  #   updated.
  # * If the update fails any validations, re-display the form with the
  #   appropriate error messages.

  scenario 'edit an existing show' do
    visit '/television_shows'
    click_link('Game of Thrones (HBO)')
    click_link('Edit')

    expect(page).to have_field('television_show[title]', with: 'Game of Thrones')
    expect(page).to have_field('television_show[network]', with: 'HBO')
    expect(page).to have_field('television_show[starting_year]', with: '2011')
    expect(page).to have_field('television_show[ending_year]')
    expect(page).to have_select('television_show[genre]', selected: 'Fantasy')
    expect(page).to have_field('television_show[synopsis]')

    fill_in('television_show[title]', with: 'Breaking Bad')
    fill_in('television_show[network]', with: 'AMC')
    fill_in('television_show[starting_year]', with: '2008')
    fill_in('television_show[ending_year]', with: '2013')
    select('Drama', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'Chemistry teacher Walter White becomes a meth cook to pay for his cancer treatment.')
    click_button('Update TV Show')
    click_link('Breaking Bad (AMC)')

    expect(page).to have_content('Breaking Bad')
    expect(page).to have_content('AMC')
    expect(page).to have_content('2008')
    expect(page).to have_content('2013')
    expect(page).to have_content('Drama')
    expect(page).to have_content('Chemistry teacher Walter White becomes a meth cook to pay for his cancer treatment.')
  end

  scenario 'fail to add a show with invalid information' do
    # no title
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: '')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content("Title can't be blank")

    # no network
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: '')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content("Network can't be blank")

    # no starting year
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content("Starting year can't be blank")

    # starting year not a number

    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '199A')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content('Starting year is not a number')

    # synopsis too long
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: SPONGEBOB_SYNOPSIS)
    click_button('Update TV Show')

    expect(page).to have_content('Synopsis is too long (maximum is 5000 characters)')

    # starting year before 1900
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1799')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content('Starting year must be greater than 1900')

    # ending year before 1900
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    fill_in('television_show[ending_year]', with: '1799')
    select('Comedy', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content('Ending year must be greater than 1900')

    # genre not included in list
    visit '/television_shows'
    click_link('Breaking Bad (AMC)')
    click_link('Edit')

    fill_in('television_show[title]', with: 'Spongebob Squarepants')
    fill_in('television_show[network]', with: 'Nickelodeon')
    fill_in('television_show[starting_year]', with: '1999')
    select('Choose', from: 'television_show[genre]')
    fill_in('television_show[synopsis]', with: 'WHO LIVES IN A PINEAPPLE UNDER THE SEA?')
    click_button('Update TV Show')

    expect(page).to have_content('Genre is not included in the list')
  end
end
