$setup_loader.register("spawn") do |s|

  s.client Workling::Clients::SpawnClient

  s.guard do
    Workling::Clients::SpawnClient.installed?
  end

end
