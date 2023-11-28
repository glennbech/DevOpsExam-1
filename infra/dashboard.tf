resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = <<DASHBOARD
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {

        "metrics": [
          [
            "${var.dashboard_name}",
            "ppe.violation.person.count"
          ]
        ],
        "period": 600,
        "stat": "Average",
        "region": "eu-west-1",
        "title": "Number of people in images with violations"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [

          "${var.dashboard_name}",
          "img.size.avg"
        ],
        "period": 300,
        "stat": "Average",
        "title": "Average Image Size in S3 Bucket"
      }
    }
  ]
}

DASHBOARD

}
