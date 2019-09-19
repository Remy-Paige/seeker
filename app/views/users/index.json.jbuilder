json.array!(@users) do |user|
  json.extract! user, :id
  json.url user_ticket_url(user, format: :json)
end