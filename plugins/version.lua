do

function run(msg, matches)
  return 'critech security '.. VERSION .. [[ 
  anti spammer and
  group manager robot
 by critex team
 bot version phoenix2.1]]
end

return {
  description = "Shows bot version", 
  usage = "!version: Shows bot version",
  patterns = {
    "^!version$"
  }, 
  run = run 
}

end
