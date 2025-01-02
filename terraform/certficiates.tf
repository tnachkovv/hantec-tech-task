resource "aws_acm_certificate" "server_cert" {
  private_key       = file("C:/custom_folder/server.key")
  certificate_body  = file("C:/custom_folder/server.crt")
  certificate_chain = file("C:/custom_folder/ca.crt")
#   domain_name       = "server"  
}

resource "aws_acm_certificate" "client_cert" {
  private_key       = file("C:/custom_folder/client1.domain.tld.key")
  certificate_body  = file("C:/custom_folder/client1.domain.tld.crt")
  certificate_chain = file("C:/custom_folder/ca.crt")
#   domain_name       = "client1.domain.tld"  
}
