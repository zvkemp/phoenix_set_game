watch('(.*)\.exs?') do |m|
  puts "--------------------------"
  _, dir, test = m.to_a
  # system("pushd #{dir} && elixir *test.exs && popd")
  system("mix test")
end
