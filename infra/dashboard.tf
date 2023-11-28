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
            "ppe.violation.person.count",
            { "stat": "Sum", "period": 300 }
          ]
        ],
        "period": 600,
        "stat": "Average"
        "region": "eu-west-1",
        "title": "PPE Scan Count"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${var.dashboard_name}",
            "image.size.avg",
            { "stat": "Average", "period": 600 }
          ],
        ],
        "region": "eu-west-1",
        "title": "Image Size Metrics"
      }
    }
  ]
}
DASHBOARD
}