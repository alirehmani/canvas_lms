# frozen_string_literal: true

#
# Copyright (C) 2011 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require "nokogiri"

describe CollaborationsController do
  it "properly links to the user who posted the collaboration" do
    PluginSetting.create!(name: "etherpad", settings: {})
    course_with_teacher_logged_in active_all: true, name: "teacher 1"

    UserService.register(
      service: "google_drive",
      token: "token",
      secret: "secret",
      user: @user,
      service_domain: "drive.google.com",
      service_user_id: "service_user_id",
      service_user_name: "service_user_name"
    )

    get "/courses/#{@course.id}/collaborations/"
    expect(response).to be_successful

    post "/courses/#{@course.id}/collaborations/", params: { collaboration: { collaboration_type: "EtherPad", title: "My Collab" } }
    expect(response).to be_redirect

    get "/courses/#{@course.id}/collaborations/"
    expect(response).to be_successful

    html = Nokogiri::HTML5(response.body)
    links = html.css("div.collaboration_#{Collaboration.last.id} a.collaborator_link")
    expect(links.count).to eq 1
    link = links.first
    expect(link.attr("href")).to eq "/courses/#{@course.id}/users/#{@teacher.id}"
    expect(link.text).to eq "teacher 1"
  end
end
