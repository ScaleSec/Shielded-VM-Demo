output "shielded_vm_instance_name" {
   value = google_compute_instance.shielded_vm_instance.name
   description  =  "The name of the Shielded VM instance"
}