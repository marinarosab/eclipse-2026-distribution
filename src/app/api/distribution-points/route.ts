import { NextResponse } from "next/server"
import { createServiceClient } from "@/lib/supabase-server"

export async function GET() {
  const supabase = createServiceClient()

  const { data, error } = await supabase
    .from("distribution_points")
    .select("id, name, city")
    .eq("status", "active")
    .order("city")

  if (error) {
    console.error("distribution-points:", error)
    return NextResponse.json(
      { error: "Could not load distribution points" },
      { status: 500 }
    )
  }

  return NextResponse.json({ points: data })
}