package com.github.lenguyenhcm325.coursemanagementsystembackend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Providers")
@JsonIgnoreProperties("courses")
public class Provider {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private int id;

  @NotBlank
  @Size(max = 255)
  @Column(name = "name")
  private String name;

  @OneToMany(
      mappedBy = "provider",
      cascade = {CascadeType.ALL})
  private List<Course> courses;

  @Override
  public String toString() {
    return "Provider{" + "id=" + id + ", name='" + name + '\'' + ", courses=" + courses + '}';
  }
}
