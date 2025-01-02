resource "aws_eip" "agent_eip" {
  count    = var.settings.agent.count
  instance = aws_instance.agent[count.index].id
  vpc      = true
  tags = {
    Name = "web-eip-${count.index+1}"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}