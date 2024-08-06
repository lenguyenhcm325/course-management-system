import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export default function HealthCheck() {
  return NextResponse.json({ status: "ok" }, { status: 200 });
}
