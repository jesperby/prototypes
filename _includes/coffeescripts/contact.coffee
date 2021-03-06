jQuery ($) ->
  # FIXME: POST the feedback form with Ajax
  $("aside.feedback form").submit (event) ->
    event.preventDefault()
    $('aside.feedback .initiate').remove()
    $("aside.feedback .comment").replaceWith('<div class="success">Tack, du har nu hjälpt oss att förbättra malmo.se</div>')
    $('html, body').animate
      scrollTop: $("aside.feedback").offset().top - 60
    , 100

  # Show feedback comment field
  $("aside.feedback .trigger").click ->
    $('aside.feedback h1').text("Hjälp oss att förbättra webbplatsen!")
    $('aside.feedback .initiate').remove()
    $("aside.feedback form input[name=rating]").prop("value", "Nej")

    $comment = $("aside.feedback .comment")
    $comment.slideDown(100)
    $comment.find("textarea").focus()
    $('html, body').animate
      scrollTop: $("aside.feedback h1").offset().top - 60
    , 100

  # Show contact us form
  $("aside.contact-us .write-to-us").click (event) ->
    event.preventDefault()
    $trigger = $(@)

    # Clone form template
    $form = $("#contact-us-form-template").clone()
    $form.removeAttr("id")

    # Post the form w/ Ajax on submit
    $form.submit (event) ->
      event.preventDefault()
      $form.find("input[type=submit]").val("Skickar meddelande ...").attr("disabled", "disabled")
      $.ajax
        type: "POST"
        url: $trigger.attr('data-action')
        data: $form.serialize() + "&contactid=#{$trigger.attr('data-contact-id')}"
        success: (data) ->
          # Replace the form with the repsonce html
          # This is either
          #   * the success message
          #   * the form w/ validation messages
          $form.replaceWith(data)
        error: (x, y, z) ->
          # Server error or timeout, nothing to do
          # FIXME: Uncomment the real error message
          # $form.after('<div class="error">Ett fel inträffade, vänligen försök senare eller skicka ditt meddelande till nedanstående e-postadress.</div>')
          # FIXME: Remove this dummy success messsage used in the prototype
          $form.replaceWith('<div class="success">Ditt meddelande har skickats till vagledningscentrum@malmo.se.</div>')

    # Replace the trigger w/ the form
    $trigger.replaceWith($form.show())

    # Scroll to top of form
    $('html, body').animate
      scrollTop: $form.offset().top - 45
    , 100

  # District selector for Contact us
  if $("aside.contact-us.multi-district").length
    $.cookie.json = true

    # The form
    $chooseDistrict = $("#choose-district")

    # Prevent the form for being submited
    $chooseDistrict.submit -> event.preventDefault()

    # Selectbox
    $selectDistrict = $chooseDistrict.find("select")

    showDistrictContact = (district) ->
      # Hide all contact cards
      $("aside.contact-us.multi-district .vcard").hide()

      # Show selected contact card
      $("#district-#{district}").show()

      # Set district in select menu
      $selectDistrict.val district

      # Set selected district in cookie
      $.cookie('city-district', district, { expires: 365, path: '/' } )

    # Select district from cookie on load
    storedDistrict = $.cookie('city-district')
    if !!storedDistrict
      showDistrictContact storedDistrict
    else
      $("aside.contact-us.multi-district .vcard").hide()

    # District selector is changed by user or address search
    $selectDistrict.change ->
      showDistrictContact $(@).val()

    # Autocomplete for street addresses
    # Get address suggestions w/ districts from SBK's map service
    $chooseDistrict.find("input").autocomplete
      source: (request, response) ->
        $.ajax
          url: "//kartor.malmo.se/api/v1/district_from_address/"
          dataType: "jsonp"
          data:
            q: request.term
            items: 10
            group_by: "district"
          success: (data) ->
            response $.map data.addresses, (item) ->
              label: item.name
              district: item.towndistrict
      minLength: 2
      select: (event, ui) ->
        showDistrictContact ui.item.district.toLowerCase()
