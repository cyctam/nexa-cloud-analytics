data "archive_file" "frontend" {
  type        = "zip"
  source_dir  = "../frontend"
  output_path = "${path.module}/builds/frontend.zip"
}

resource "aws_amplify_app" "dashboard" {
  name     = "${var.project_prefix}-analytics-dashboard"
  platform = "WEB"
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.dashboard.id
  branch_name = "main"
  stage       = "PRODUCTION"
}